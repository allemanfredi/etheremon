const  Web3 = require('web3');
const { CallbackEmitter } = require('callback-emitter');
const config = require('./config');
const PokedexContract = require('./build/contracts/Pokedex');


const Pokedex =  {

    constructor(){
        this.web3 = null;
        this.pokemonContract = null;
        this.currentAccount = null;
        this.contractAddress = config.contractAddress;
        this.currentBlockNumber = 0;
        this.defaultBlockNumber = config.contractBlockNumberCreation; //smart contract deployment block height
    },

    async init() {

        try{
            
            if (typeof web3 !== 'undefined') {
                this.web3 = new Web3(window.web3.currentProvider);
                
                //enable metamask interaction with this app
                await window.ethereum.enable();
            } else {
                CallbackEmitter.emit('error',' Install Metamask');
                return;
            }

            //get the current account address
            const accounts = await this.web3.eth.getAccounts();
            this.currentAccount = accounts[0];

            //contract instance
            this.pokemonContract = new this.web3.eth.Contract(PokedexContract.abi,this.contractAddress, {
                defaultAccount: this.currentAccount, // default from address
            });
            
            //event listeners
            this.registerEventsListener();

        }catch(err){
            CallbackEmitter.emit('error',err.message);
        }
    },

    async buy() {
        try{;
            await this.pokemonContract.methods.buyPokemon().send({
                from: this.currentAccount,
                value: this.web3.utils.toWei('0.01', 'ether') 
            });
        }catch(err){
            CallbackEmitter.emit('error',err.message);
        }
    },

    registerEventsListener() {
        this.pokemonContract.events.allEvents()
        .on('data', async e => {
            console.log(e);
        });
    }

}

module.exports = Pokedex;