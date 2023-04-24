// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MiladyPoland.sol";

contract MiladyPolandTest is Test {
    MiladyPoland public miladyPoland;

    function setUp() public {
        miladyPoland = new MiladyPoland(
            0x10A8Fc644A4135EF9f11A56b05Ab7c5eA7888c33,
            0x49276d20696e20796f75722077616c6c73000000000000000000000000000000
        );
    }

    function test_ReceiverReceivesFiveNFts() public {
        uint256 receiverBalance = miladyPoland.balanceOf(0x10A8Fc644A4135EF9f11A56b05Ab7c5eA7888c33);
        assertEq(5, receiverBalance);
    }

}
