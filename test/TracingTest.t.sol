//SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Test } from "forge-std/Test.sol";
import { ISwapRouter } from "./interfaces/ISwapRouter.sol";
import { IQuoterV2 } from "./interfaces/IQuoterV2.sol";
import { IERC20 } from "forge-std/mocks/MockERC20.sol";

contract TracingTest is Test { 
    address public constant VITALIK = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
    address public constant UNISWAP_V3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address public constant UNISWAP_QUOTER_V2 = 0x61fFE014bA17989E743c5F6cB21bF9697530B21e;
    address public constant WETH_USDC_POOL = 0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    uint24 public constant WETH_USDC_POOL_FEE = 500;

    uint256 public mainnetFork;
    ISwapRouter public swapRouter;
    IQuoterV2 public quoterV2;
    IERC20 public wethToken;

    function setUp() public {
        mainnetFork = vm.createFork("mainnet_rpc");
        swapRouter = ISwapRouter(UNISWAP_V3_ROUTER);
        quoterV2 = IQuoterV2(UNISWAP_QUOTER_V2);
        wethToken = IERC20(WETH);

        vm.label(VITALIK, "Vitalik");
        vm.label(UNISWAP_V3_ROUTER, "Uni V3 router");
        vm.label(UNISWAP_QUOTER_V2, "Uni V3 Quoter V2");
        vm.label(WETH_USDC_POOL, "Uni V3 WETH-USDC pool");
        vm.label(WETH, "WETH");
        vm.label(USDC, "USDC");
    }

    function testVitalikSwapping() public {
        uint256 swapAmount = 1e18; //1 WETH
        vm.selectFork(mainnetFork);

        vm.startPrank(VITALIK);
        wethToken.approve(UNISWAP_V3_ROUTER, swapAmount);

       uint256 amountOutMin = _getQuote();

         ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: WETH,
                tokenOut: USDC,
                fee: WETH_USDC_POOL_FEE,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: swapAmount,
                amountOutMinimum: amountOutMin,
                sqrtPriceLimitX96: 0
            });

        swapRouter.exactInputSingle(params);

        vm.stopPrank();
    }

    function _getQuote() internal returns (uint256) {
      IQuoterV2.QuoteExactInputSingleParams memory quoteParams =  IQuoterV2.QuoteExactInputSingleParams({
            tokenIn: WETH,
            tokenOut: USDC,
            amountIn: 1e18,
            fee: WETH_USDC_POOL_FEE,
            sqrtPriceLimitX96: 0
        });

        ( uint256 amountOut, , , ) = quoterV2.quoteExactInputSingle(quoteParams);

        return amountOut;
    }

}