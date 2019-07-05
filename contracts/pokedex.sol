pragma solidity >=0.5.0 <0.6.0;

import "./pokemonOwnership.sol";

contract Pokedex is PokemonOwnership {
    
    constructor() public{}
    
    //get a list of all pokemon id given the owner address
    function pokemonsOfOwner(address _owner) external view returns(uint256[] memory) {
        uint256 pokemonCount = ownerPokemonCount[_owner];

        if (pokemonCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](pokemonCount);
            uint256 totalPokemons = pokemons.length;
            uint256 resultIndex = 0;

            // We count on the fact that all pokemons have IDs starting at 1 and increasing
            uint256 pokemonId;

            for (pokemonId = 1; pokemonId <= totalPokemons; pokemonId++) {
                if (pokemonsToOwner[pokemonId] == _owner) {
                    result[resultIndex] = pokemonId;
                    resultIndex++;
                }
            }

            return result;
        }
    }
    
    //get pokemon data given it's id
    function getPokemon(uint256 id) external view returns(string memory){
        
        Pokemon memory pokemon = ownersOfPokemon[msg.sender][id];
        return pokemon.name;
    }
}