// SPDX-License-Identifier: MIT




pragma solidity ^0.8.16;


error WalletLimitExceeded();
error NoMoney();
error PriceMustbemultipleofunit();
error OhYouSneaky();
error FreeSaleNoMore();
error GeneralMintClosed();
error TooMany();  
error Locked();
error OutOfStock();
error NotYou();
error NotTokenOwner();
error gowno();
error chujciwdupe();
error YouMustOwnTheGenesisToken();



import "lib/ERC721A/contracts/extensions/ERC721AQueryable.sol";
import "lib/solady/src/utils/SafeTransferLib.sol";
import "lib/solmate/src/auth/Owned.sol"; 
import "./ECDSA.sol";
import "./LibString.sol";

contract MiladyPoland is  Owned(msg.sender), ERC721AQueryable{
     using ECDSA for bytes32;


   uint8 public saleState;
    
    uint256  public constant RESERVED_NFTS = 5;
    uint256  public constant maxSupply = 6000;
    uint256 public constant maxMiladyMint = 3;
    uint256 public constant MaxFreePerWallet = 1;
    uint256 public constant MaxPaidPerWallet= 5;
   
    IERC721A immutable MILADY_TOKEN_CONTRACT;
    address public signer;

  
     
      //mapping(uint256 => bytes) public tokenMsg;




     uint16 private _publicPriceUnits;
     uint16 private _miladyPriceUnits;


    uint256 public constant PRICE_UNIT = 0.0003 ether;

     uint8 public constant SALE_STATE_CLOSED = 0;
    uint8 public constant SALE_STATE_FREE = 1;
    uint8 public constant SALE_STATE_GENERAL = 2;

   string private _baseTokenURI;
    string private _contractURI;

   mapping(address => uint256) private miladybalances;
   
   bool public paused;

  mapping(address => uint256) public friendsAndFamilyMints;

            constructor(
           address receiver,
           address _miladyTokenAddress,
           bytes32  message
     )  ERC721A("MiladyPoland", "MPL") {
        
        //_miladyPriceUnits = _toPriceUnits(0.00 ether);
        //_publicPriceUnits = _toPriceUnits(0.06 ether);
        //paused = true; // Must be initialized to true.
          _mintERC2309(receiver, RESERVED_NFTS);
          MILADY_TOKEN_CONTRACT = IERC721A(_miladyTokenAddress);
          message = (message);
    
     }


     modifier callerIsUser(){
    if (tx.origin != msg.sender)
    revert OhYouSneaky();
    _;
}


     function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

   function _toPriceUnits(uint256 price) private pure returns (uint16) {
        unchecked {
            if (price % PRICE_UNIT != 0) revert PriceMustbemultipleofunit();
            require((price /= PRICE_UNIT) <= type(uint16).max, "Overflow.");
              return uint16(price);
        }
    }

    function _toPrice(uint16 priceUnits) private pure returns (uint256) {
        return uint256(priceUnits) * PRICE_UNIT;
    }

// zrobić assembly do owner of milady wyciagnać hash tego siga ????

//uint256 friendsAndFamilyBalance = IERC721(0x5Af0D9827E0c53E4799BB226655A1de152A425a5).balanceOf(_to);
//require(friendsAndFamilyBalance > 0 || friendsAndFamilyBalance2 > 0,
            
      function MiladyMint(uint256 quantity, bytes calldata signature) external payable 
              





        requireSignature(signature)
         { unchecked {
            
                if (miladybalances(msg.sender) < 1 )
             
      revert YouMustOwnTheGenesisToken();
            if (_totalMinted()+ quantity > maxMiladyMint + RESERVED_NFTS)
             revert OutOfStock();
            if ( saleState != SALE_STATE_FREE|| saleState == 0 )
            revert FreeSaleNoMore(); 
                if ((_numberMinted(msg.sender) - _getAux(msg.sender)) + quantity > MaxFreePerWallet)
          revert WalletLimitExceeded();
            
                           
        }
        
        _mint(msg.sender, quantity);
         }




 function balanceOfSenderInAnotherContract(address erc721Address) public view returns (uint256) {
        uint256 miladybalance;
        bytes4 balanceOfSelector = bytes4(keccak256("balanceOf(address)"));

        assembly {
            let ptr := mload(0x40) // Get a free memory pointer
            mstore(ptr, balanceOfSelector) // Store the function selector (first 4 bytes of the hash of "balanceOf(address)")
            mstore(add(ptr, 0x04), caller()) // Store the `msg.sender` address after the function selector

            // Perform the external call to the target contract
            let success := staticcall(
                gas(),
                erc721Address,
                ptr, // Input pointer
                0x24, // Input size (4 bytes for the function selector + 32 bytes for the address)
                ptr, // Use the same memory pointer for output
                0x20 // Output size (32 bytes for the uint256 balance)
            )

            if iszero(success) {
                revert(0, 0) // Revert if the external call failed
            }

            miladybalance := mload(ptr) // Load the balance from the returned value
        }

        return miladybalance;
    }





  function mint(uint256 quantity)external payable 
     requireExactPayment(_publicPriceUnits, quantity)
      { unchecked {

          if (_totalMinted()+ quantity >maxSupply) revert OutOfStock();
          if (saleState != SALE_STATE_GENERAL|| saleState == 0) revert 
            GeneralMintClosed();
          if ((_numberMinted(msg.sender) - _getAux(msg.sender)) + quantity > MaxPaidPerWallet)
          revert WalletLimitExceeded();
      }
        _mint(msg.sender, quantity);
    }



   modifier requireSignature(bytes calldata signature) {
        require(
            keccak256(abi.encode(msg.sender)).toEthSignedMessageHash().recover(signature) == signer,
            "Invalid signature."
        );
        _;
    }





 modifier requireExactPayment(uint16 priceUnits, uint256 quantity) {
       unchecked {
         if (msg.value !=_toPrice(priceUnits)* quantity) revert NoMoney();        
        }
       _;
    }
  
  function publicPrice() external view returns (uint256) {
        return _toPrice(_publicPriceUnits);
    }
 
function setPublicPrice(uint256 value) external onlyOwner {
        _publicPriceUnits = _toPriceUnits(value);
    }

  function withdraw() external payable onlyOwner {
    SafeTransferLib.safeTransferETH(msg.sender, address(this).balance);
  }
   //@dev URI functions.


         function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

        function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721A, IERC721A) returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
            string memory baseURI = _baseURI();
            return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenId))) : ''; //
         }
   
      function setSaleState(uint8 value) external onlyOwner {
        if (saleState != 0) {
            require(maxSupply != 0, "max supply not set");
        }
        saleState = value;
    }
     
 function setSigner(address value) external onlyOwner {
        require(value != address(0), "Signer must not be the zero address.");
        signer = value;
    }





function ownershipOf(uint256 id) external view returns (TokenOwnership memory) {
    return _ownershipOf(id);
}

 function getTranferAmount(uint256 id) external view returns (uint256) {
        TokenOwnership memory ownership = _ownershipOf(id);
        uint256 transferAmount = ownership.extraData;
        return transferAmount;
    
    }
function  _extraData (
    address,
    address,
    uint24 previousExtraData
) internal pure override virtual returns (uint24) 
{
    
    
    return ++previousExtraData;
   
}


//function hashCompareWithLengthCheck(uint256 tokenId, uint256 tokenId2 ) public view returns  (bool) {
  //if (msg.sender != ownerOf(tokenId)) {
  //    revert NotTokenOwner();
 // }
   // if(bytes((tokenMsg[tokenId])).length != bytes((tokenMsg[tokenId2])).length) {
  //      return false;
   // } else {
   //     return keccak256(tokenMsg[tokenId]) == keccak256(tokenMsg[tokenId]);
   // }

}