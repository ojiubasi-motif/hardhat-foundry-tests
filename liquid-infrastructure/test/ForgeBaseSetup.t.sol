//SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.12; // Force solidity compliance

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {TestERC20A} from '../contracts/TestERC20A.sol';
import {TestERC20B} from '../contracts/TestERC20B.sol';
import {TestERC20C} from '../contracts/TestERC20C.sol';
import {LiquidInfrastructureERC20} from '../contracts/LiquidInfrastructureERC20.sol';

contract deployErc20ABC {
    TestERC20A public erc20A;
    TestERC20B public erc20B;
    TestERC20C public erc20C;

    address public erc20Aaddr;
    address public erc20Baddr;
    address public erc20Caddr;

    LiquidInfrastructureERC20 public liquidInfraERC20;

    function deployContracts() public returns(address[3] memory erc20s) {
        erc20A = new TestERC20A();
        erc20B = new TestERC20B();
        erc20C = new TestERC20C();
        
        erc20Aaddr = address(erc20A);
        erc20Baddr = address(erc20B);
        erc20Caddr = address(erc20C);
        return [erc20Aaddr, erc20Baddr, erc20Caddr];
    }
/**
 * constructor(
        string memory _name,
        string memory _symbol,
        address[] memory _managedNFTs,
        address[] memory _approvedHolders,
        uint256 _minDistributionPeriod,
        address[] memory _distributableErc20s
    ) 
 * 
 */
    function deployLiquidERC20(
        string memory _name,
        string memory _symbol,
        address[] memory _managedNFTs,
        address[] memory _approvedHolders,
        uint256 _minDistributionPeriod,
        address[] memory _distributableErc20s
    ) public returns(LiquidInfrastructureERC20) {
        liquidInfraERC20  = new LiquidInfrastructureERC20(_name, _symbol, _managedNFTs, _approvedHolders, _minDistributionPeriod, _distributableErc20s);
        return liquidInfraERC20;
    }
}