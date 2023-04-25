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
error BaseURIIsLocked();

import "lib/ERC721A/contracts/extensions/ERC721AQueryable.sol";
import "lib/solady/src/utils/SafeTransferLib.sol";
import "lib/solmate/src/auth/Owned.sol";
import "lib/solady/src/utils/LibString.sol";

contract MiladyPoland is Owned(msg.sender), ERC721AQueryable {
    uint8 public saleState;
    uint8 private baseURILocked = 1;
    uint8 public constant SALE_STATE_CLOSED = 0;
    uint8 public constant SALE_STATE_FREE = 1;
    uint8 public constant SALE_STATE_GENERAL = 2;

    uint16 private _publicPriceUnits;
    uint16 private _miladyPriceUnits;

    uint256 public constant RESERVED_NFTS = 5;
    uint256 public constant maxSupply = 6000;
    uint256 public constant maxMiladyMint = 3;
    uint256 public constant MaxFreePerWallet = 1;
    uint256 public constant MaxPaidPerWallet = 5;
    uint256 public constant PRICE_UNIT = 0.0003 ether;

    address constant MILADY_TOKEN_CONTRACT =
        0x5Af0D9827E0c53E4799BB226655A1de152A425a5;
    address public signer;

    string private _baseTokenURI;
    string private _contractURI;

    bool public paused;

    constructor(
        address receiver
    )
        // bytes32 message (odkomentowac potem)
        ERC721A("MiladyPoland", "MPL")
    {
        _mintERC2309(receiver, RESERVED_NFTS);
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

    // external zeby dzialalo w testach, potem trzeba zmienic!!

    function getMiladyBalance(address _address) internal view returns (uint256 miladyBalance) {
        assembly {
            // Prepare calldata for the staticcall
            mstore(0x0, shl(224, 0x70a08231)) // Shift the function selector to the left by 224 bits
            mstore(0x4, _address) // Store the msg.sender (caller) at position 0x4

            // Perform the staticcall
            let success := staticcall(
                gas(),
                0x5Af0D9827E0c53E4799BB226655A1de152A425a5,
                0x0,
                0x24,
                0x0,
                0x20
            )

            // Check if the call was successful
            if iszero(success) {
                revert(0, 0)
            }

            // Retrieve the result and store it in miladyBalance
            miladyBalance := mload(0x0)
        }

        return miladyBalance;
    }

    function MiladyMint(uint256 quantity) external payable {
        unchecked {
            if (getMiladyBalance(msg.sender) == 0)
                revert NotYou();
            if (_totalMinted() + quantity > maxMiladyMint + RESERVED_NFTS)
                revert OutOfStock();
            if (saleState != SALE_STATE_FREE || saleState == 0)
                revert FreeSaleNoMore();
            if (
                (_numberMinted(msg.sender) - _getAux(msg.sender)) + quantity >
                MaxFreePerWallet
            ) revert WalletLimitExceeded();
        }

        _mint(msg.sender, quantity);
    }

    function mint(
        uint256 quantity
    ) external payable requireExactPayment(_publicPriceUnits, quantity) {
        unchecked {
            if (_totalMinted() + quantity > maxSupply) revert OutOfStock();
            if (saleState != SALE_STATE_GENERAL || saleState == 0)
                revert GeneralMintClosed();
            if (
                (_numberMinted(msg.sender) - _getAux(msg.sender)) + quantity >
                MaxPaidPerWallet
            ) revert WalletLimitExceeded();
        }
        _mint(msg.sender, quantity);
    }

    modifier requireExactPayment(uint16 priceUnits, uint256 quantity) {
        unchecked {
            if (msg.value != _toPrice(priceUnits) * quantity) revert NoMoney();
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

    function setBaseURI(string calldata baseURI) external onlyOwner {
        if (baseURILocked == 2) revert BaseURIIsLocked();
        _baseTokenURI = baseURI;
    }

    function lockBaseURI() external onlyOwner {
        baseURILocked = 2;
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
}
