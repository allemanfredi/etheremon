pragma solidity >=0.5.0 <0.6.0;

import "./ownable.sol";
import "./safemath.sol";

import "./oraclize/oraclizeAPI_0.5.sol";


contract PokemonShop is Ownable , usingOraclize  {
    
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;
    
    event NewPokemon(uint pokemonId, string name);
    event LogNewOraclizeQuery(string description);
    event generatedRandomNumber(uint256 number);
    event LogError(string description);

    struct Pokemon {
        string name;
    }
    
    uint256 constant NUM_RANDOM_BYTES_REQUESTED = 7;
    uint256 constant RANDOM_NUMBER = 0;     //generated random number
    uint256 constant API_CALL = 1;          //results from api call
    uint256 constant POKEMONS_NUMBER = 807;  //number of pokemons present in pokeapi
    uint256 processStatus;
    
    address currentMessageSender;
    
    bool isBuying;

    Pokemon[] public pokemons;
    
    mapping (uint => address) public pokemonsToOwner;
    mapping (address => uint) ownerPokemonCount;
    mapping (address => mapping (uint => Pokemon)) ownersOfPokemon;
    
    constructor() public{
        isBuying = false;
        processStatus = RANDOM_NUMBER;
    }
    
      
    function __callback(bytes32 _queryId,string memory _result) public {
        require(msg.sender == oraclize_cbAddress());
        
        bool isDone = false;
        
        if ( processStatus == RANDOM_NUMBER ){

            //convert from bytes to int
            uint256 ceiling = POKEMONS_NUMBER + 1;
            uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % ceiling;
            
            emit generatedRandomNumber(randomNumber);
            
            //convert id from int to string and use this number to get a pokemon from pokeAPI by using oraclize again
            string memory stringRandomNumber = uint2str(randomNumber);
            string memory url = strConcat("json(https://pokeapi.co/api/v2/pokemon/",stringRandomNumber,"/).name");
            oraclize_query("URL", url);
            emit LogNewOraclizeQuery("Oraclize url query was sent, standing by for the answer...");
            
            //set smart contract state
            processStatus = API_CALL;
            
            //in order to don't enter in processStatus == API_CALL
            isDone = true;
        }
        if ( processStatus == API_CALL && !isDone ){ 
            
            //set the ownership
            Pokemon memory newPokemon = Pokemon(_result);
            uint id = pokemons.push(newPokemon) - 1;
            pokemonsToOwner[id] = currentMessageSender;
            ownersOfPokemon[currentMessageSender][id] = newPokemon;
            ownerPokemonCount[currentMessageSender] = ownerPokemonCount[currentMessageSender].add(1);
            
            emit NewPokemon(id,_result);

            //set smart contract state
            processStatus = RANDOM_NUMBER;
            
            //reset msg.sender
            currentMessageSender = address(0);
            
            //another user can call buyPokemon = request terminated
            isBuying = false;
        }
        
    }
    
    function buyPokemon() public payable{
        //0.005 = (0.004 * 2) + 0.001 => 0.004 = default oraclize ether value, 0.001 = price to generate a pokemon
        require(msg.value >= 0.005 ether,"Pokemons are not free!"); 
        //an user could call buyPokemon and become the currentMessageSender and get a pokemo buyed by another user since the assignment is done in the callback
        require(isBuying == false,"Wait for completion"); 
        
        //save the msg.sender in order to be able to properly assing the pokemon after having fetched the api
        currentMessageSender = msg.sender;
        
        //start operation
        isBuying = true;
        processStatus = RANDOM_NUMBER;
        
        uint256 QUERY_EXECUTION_DELAY = 0;
        uint256 GAS_FOR_CALLBACK = 200000;
        oraclize_newRandomDSQuery(QUERY_EXECUTION_DELAY,NUM_RANDOM_BYTES_REQUESTED,GAS_FOR_CALLBACK);
        
        emit LogNewOraclizeQuery("Oraclize random number query was sent, standing by for the answer...");
    }

}