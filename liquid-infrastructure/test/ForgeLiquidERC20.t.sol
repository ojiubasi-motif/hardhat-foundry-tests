pragma solidity 0.8.12; // Force solidity compliance

import {deployErc20ABC} from "./ForgeBaseSetup.t.sol";
import {LiquidInfrastructureERC20} from "../contracts/LiquidInfrastructureERC20.sol";
import {LiquidInfrastructureNFT} from "../contracts/LiquidInfrastructureNFT.sol";

import "forge-std/Test.sol";

contract liquidERC20 is Test, deployErc20ABC {
    // get some random private keys and their addresses to sign trx
    address nftAccount1 = makeAddr("nftAccount1");
    address nftAccount2 = makeAddr("nftAccount2");
    address nftAccount3 = makeAddr("nftAccount3");
    uint256 erc20Owner = uint256(keccak256("erc20Owner"));
    uint256 holder1 = uint256(keccak256("holder1"));
    uint256 holder2 = uint256(keccak256("holder2"));
    uint256 holder3 = uint256(keccak256("holder3"));
    uint256 holder4 = uint256(keccak256("holder4"));
    address badSigner = makeAddr("badSigner");

    address erc20OwnerAddress = vm.addr(erc20Owner);
    address[] erc20Addresses;

    LiquidInfrastructureERC20 public _liquidInfraERC20;
    LiquidInfrastructureNFT public NFT1;
    LiquidInfrastructureNFT public NFT2;

    function test_liquidErc20Fixture() public {
        vm.startPrank(erc20OwnerAddress);
        address[3] memory erc20s = deployContracts();
        erc20Addresses = [erc20s[0], erc20s[1], erc20s[2]];

        address[] memory emptyArray = new address[](0);

        _liquidInfraERC20 = deployLiquidERC20(
            "Infra",
            "INFRA",
            emptyArray,
            emptyArray,
            500,
            erc20Addresses
        );
        vm.stopPrank();

        address holder1Addr = vm.addr(erc20Owner);

        assertEq(_liquidInfraERC20.totalSupply(), 0);
        assertEq(_liquidInfraERC20.name(), "Infra");
        assertEq(_liquidInfraERC20.symbol(), "INFRA");

        vm.expectRevert();
        address NftInArray = _liquidInfraERC20.ManagedNFTs(0); //check for the first item in the array

        assertEq(_liquidInfraERC20.isApprovedHolder(holder1Addr), false);

        vm.expectRevert();
        _liquidInfraERC20.mint(holder1Addr, 1000);

        assertEq(_liquidInfraERC20.balanceOf(holder1Addr), 0);
    }

    function test_basicNftManagementTests() public {
        vm.prank(nftAccount1);
        NFT1 = new LiquidInfrastructureNFT("LiquidInfrastructureNFT");

        vm.prank(nftAccount2);
        NFT2 = new LiquidInfrastructureNFT("LiquidInfrastructureNFT");

        console.log("Manage");

        transferNftToErc20AndManage(_liquidInfraERC20, NFT1, nftAccount1);
        address nft1Address = address(NFT1);
        _liquidInfraERC20.releaseManagedNFT(nft1Address, nftAccount1);

        vm.expectEmit();
        emit _liquidInfraERC20.ReleaseManagedNFT(NFT1, nftAccount1);
        address nft1Owner = NFT1.ownerOf(NFT1.AccountId());
        assertEq(nft1Owner, nftAccount1);

        console.log("Bad Signer");
        failToManageNFTBadSigner(_liquidInfraERC20, NFT2, nftAccount2);
        console.log("Not NFT Owner");
        failToManageNFTNotOwner(_liquidInfraERC20,NFT1);
    }

    function transferNftToErc20AndManage(
        LiquidInfrastructureERC20 infraERC20,
        LiquidInfrastructureNFT nftToManage,
        address nftOwner
    ) private {
        address infraAddress = address(infraERC20);
        address accountId = nftToManage.AccountId();

        bool success = nftToManage.transferFrom(
            nftOwner,
            infraAddress,
            accountId
        );
        assertEq(success, true, "unexpected nft owner");
        assertEq(nftToManage.ownerOf(accountId), infraAddress);

        address nftToManageAddress = address(nftToManage);
        infraERC20.addManagedNFT(nftToManageAddress);
        vm.expectEmit();
        emit infraERC20.AddManagedNFT(nftToManageAddress);
    }

    function failToManageNFTBadSigner(
        LiquidInfrastructureERC20 infraERC20,
        LiquidInfrastructureNFT nftToManage,
        address nftOwner
    ) private {
        address infraAddress = address(infraERC20);
        address nftAddress = address(nftToManage);
        address accountId = nftToManage.AccountId();

        vm.startPrank(badSigner);
        bool success = nftToManage.transferFrom(
            nftOwner,
            infraAddress,
            accountId
        );
        assertEq(success, true);
        // assertEq(nftToManage.ownerOf(accountId), infraAddress);

        vm.expectRevert("Ownable: caller is not the owner");
        infraERC20.addManagedNFT(nftAddress);

        vm.stopPrank();
    }

    function failToManageNFTNotOwner(
        LiquidInfrastructureERC20 infraERC20,
        LiquidInfrastructureNFT nftToManage
    ) private {
        address nftAddress = address(nftToManage);
        vm.startPrank(badSigner);
        vm.expectRevert("this contract does not own the new ManagedNFT");
        infraERC20.addManagedNFT(nftAddress);
        vm.stopPrank();
    }
}
