pragma solidity >=0.5.0 <0.6.0;

import "./erc721.sol";
import "./safemath.sol";
import "./pokemonShop.sol";


contract PokemonOwnership is ERC721 , PokemonShop{

  using SafeMath for uint256;

  mapping (uint => address) pokemonApprovals;

  function balanceOf(address _owner) external view returns (uint256) {
    return ownerPokemonCount[_owner];
  }

  function ownerOf(uint256 _tokenId) external view returns (address) {
    return pokemonsToOwner[_tokenId];
  }

  function _transfer(address _from, address _to, uint256 _tokenId) private {
    ownerPokemonCount[_to] = ownerPokemonCount[_to].add(1);
    ownerPokemonCount[msg.sender] = ownerPokemonCount[msg.sender].sub(1);
    pokemonsToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
      require (pokemonsToOwner[_tokenId] == msg.sender || pokemonApprovals[_tokenId] == msg.sender);
      _transfer(_from, _to, _tokenId);
    }

  function approve(address _approved, uint256 _tokenId) external payable onlyOwner {
      pokemonApprovals[_tokenId] = _approved;
      emit Approval(msg.sender, _approved, _tokenId);
    }

}
