// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MiladyPoland.sol";

//0x60D4496FfaeF491e6BE88D55dcB511F513390486 milady i remilio

contract MiladyPolandTest is Test {
    MiladyPoland public miladyPoland;
    // address public randomUser = address(0x5E11E1);
    address public kryptopaul = 0x60D4496FfaeF491e6BE88D55dcB511F513390486;

    function setUp() public {
        miladyPoland = new MiladyPoland(
            0x10A8Fc644A4135EF9f11A56b05Ab7c5eA7888c33
            // 0x49276d20696e20796f75722077616c6c73000000000000000000000000000000 (odkomentowac potem)
        );
        miladyPoland.setSaleState(1);
    }

    function test_ReceiverReceivesFiveNFts() public {
        uint256 receiverBalance = miladyPoland.balanceOf(
            0x10A8Fc644A4135EF9f11A56b05Ab7c5eA7888c33
        );
        assertEq(5, receiverBalance);
    }

    // Milady Mint section
    function test_MiladyHolderCanMint() public {
        vm.prank(kryptopaul);
        miladyPoland.MiladyMint(1);
        uint256 balance = miladyPoland.balanceOf(
            kryptopaul
        );
        assertEq(balance, 1);
    }

    function test_MiladyHolderCantMintMoreThanOne() public {
        vm.startPrank(kryptopaul);
        miladyPoland.MiladyMint(1);
        vm.expectRevert();
        miladyPoland.MiladyMint(1);
        vm.stopPrank();

    }

    function test_NotMiladyHolderCantMint() public {
        vm.expectRevert();
        miladyPoland.MiladyMint(1);
    }

    // Normal mint section
    function test_userCanMint() public {
        miladyPoland.mint{value: 2 ether}(1);
    }
}
