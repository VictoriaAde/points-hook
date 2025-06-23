// SPDX -License-Identifier: MIT
pragma solidity ^0.8.25;
import {BaseHook} from "v4-periphery/src/utils/BaseHook.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {ERC1155} from "solmate/src/tokens/ERC1155.sol";
import  {PoolId} from "v4-core/types/PoolId.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol"; 
import {SwapParams} from "v4-core/types/PoolOperation.sol";
import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";

contract PointsHook is BaseHook, ERC1155 {
    constructor(IPoolManager _manager) BaseHook(_manager) {}

    function getHooksPermissions() 
    public
    pure 
    override
    returns (Hooks.Permissions memory)
    {
      return 
        Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: false,
            afterSwap: true, //  afterSwap = true
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    function uri (uint256) public view override returns (string memory) {
        return "";
    }

    funtion _afterSwap(address, PoolKey calldata, SwapParams calldata, BalanceDelta, bytes calldata) internal override returns (bytes4, int128) {
         /*     
        1. make sure we're operating in a ETH/TOKEN pool of some sort i.e. ETH is one of the tokens

        2. make sure the swap is for ETH → TOKEN, not the other way around


        3. calculate amount of points to give out




        4. mint points


        */
        
        // byte4 returns value of every hook function = the function selector itself
        // second returns value in this case = smth to do with return delta hooks 
        returns (this.afterSwap.selector, 0);
    }

    function _assignPoints(
        PoolId poolId,
        byte calldata hookData,
        uint points,
        ) internal {
            // if user didn't provide a hookData, no points will be minted (return early)
            if hookData.length == 0 {
                return;
            }

            // try to extract a user address from hookData
            address user = abi.decode(hookData, (address));

            // if user address is not valid, return early
            if (user == address(0)) {
                return;
            }

            // mint ERC1155 tokens 
            // poolId = keccak256(poolKey)
            // bytes32 can be type casted into a uint256
            uint poolIdAsUint = uint256(PoolId.unwrap(poolId));
            _mint(user, poolIdAsUint, points, ""); // mint points to user

    }
}