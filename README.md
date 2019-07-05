![Alt text](/material/pokeball.png?raw=true "Title")


# etheremon

etheremon it's an application that allows to buy pokemons represented by token ERC721.

The Smart Contract in charge of the payment, through Oraclize, generates a random number that will be used as `id` in the following url __`https://pokeapi.co/api/v2/pokemon/{id}`__.

### Installing

```
git clone https://github.com/allemanfredi/etheremon.git
```

```
cd etheremon
```


```
npm install
```

```
truffle compile
```


### Smart Contract deployment with INFURA:


```
echo "your mnemonic" > .secret
```

Insert also your own access key to infura within __`truffle-config.json`__ 

```javascript
const infuraKey = "your infura key";
```

```
truffle migrate
```


After having deployed it, copy the Smart Contract address and the Smart Contract creation block number within __`./config/index.js`__. 

```javascript
const config = {
    contractAddress : 'your contract address',
    contractBlockNumberCreation : 'smart contract creation block number (even 0 but not null)'
}
```


__`index.js`__ contains a sort of interface to interact with the contract that can be easily integrated into javascript applications

