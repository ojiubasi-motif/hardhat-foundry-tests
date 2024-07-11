pragma solidity 0.8.12; // Force solidity compliance

import {deployErc20ABC} from './ForgeBaseSetup.t.sol';
import {LiquidInfrastructureERC20} from '../contracts/LiquidInfrastructureERC20.sol';
import "forge-std/Test.sol";

contract liquidERC20 is Test,deployErc20ABC{
    // get some random private keys to sign trx
    uint256 nftAccount1 = uint256(keccak256('signer1'));
    uint256 nftAccount2 = uint256(keccak256('signer2'));
    uint256 nftAccount3 = uint256(keccak256('signer3'));
    uint256 erc20Owner = uint256(keccak256('erc20Owner'));
    uint256 holder1 = uint256(keccak256('holder1'));
    uint256 holder2 = uint256(keccak256('holder2'));
    uint256 holder3 = uint256(keccak256('holder3'));
    uint256 holder4 = uint256(keccak256('holder4'));
    uint256 badSigner = uint256(keccak256('badSigner'));

    address erc20OwnerAddress = vm.addr(erc20Owner);
    address[] erc20Addresses;
    

    LiquidInfrastructureERC20 public _liquidInfraERC20;
   
   function test_liquidErc20Fixture() public {
        vm.startPrank(erc20OwnerAddress);
        address[3] memory erc20s = deployContracts();
        erc20Addresses = [erc20s[0], erc20s[1], erc20s[2]];

       address[] memory emptyArray = new address[](0);


        _liquidInfraERC20 = deployLiquidERC20("Infra", "INFRA", emptyArray, emptyArray, 500, erc20Addresses);
        vm.stopPrank();

        address holder1Addr = vm.addr(erc20Owner);

        assertEq(_liquidInfraERC20.totalSupply(), 0);
        assertEq(_liquidInfraERC20.name(), "Infra");
        assertEq(_liquidInfraERC20.symbol(), "INFRA");

        vm.expectRevert();
        address NftInArray = _liquidInfraERC20.ManagedNFTs(0);//check for the first item in the array

        assertEq(_liquidInfraERC20.isApprovedHolder(holder1Addr), false);

        vm.expectRevert();
        _liquidInfraERC20.mint(holder1Addr, 1000);

        assertEq(_liquidInfraERC20.balanceOf(holder1Addr), 0);
   }

   function test_basicNftManagementTests() public{
    
   }
   
}
    