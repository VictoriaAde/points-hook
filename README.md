# BUILDING MY FIRST HOOK 

A really simple "point" hook"

Assunme you have some ETH/TOKEN pool t exists We wanna ke a hook that can be attached to such kind of poos where >:

every time somebody swaps ETH for TOKEN (i.e. spends ETH, purchases TOKEN) - we issue them some "points"

This is just a PoC

## Design 

1. How many points do we give out per swap?

we're going to give 20% of the ETH spent in the swap in the form of points
e.g. if someone sells 1 ETH to purchase TOKEN, they get 20% of 1 = 20% of 1 = 0.2 POINTS


2. How do we represent these points? 

points themselves are going to be an ERC - 1155 token

ERC 1155 allows minting of "x" number of tokens that are distinct based on some sort of "key"
since the hook can be attached to multiple pools, ETH/A, ETH/B, ETH/C
points = minting some amount of ERC 1155 tokens for that pool to the user

> Q: Why not use ERC- 6909 for doing this
> A: You totally can! ERC-1155 is just a bit more familiar to people so for the first workshop i wanted to stick with this

### beforeSwap and afterSwap

this balancedelta thing is actually quite a burden to us because we're giving out points as a % of the amount of ETH that was spent in the swap 

How much ETH was spent in the swap?

this is not a question that can be answered beforeSwap because it is literally unknown until the swap happens
That's because:
1. slippage limit may hit causing a parial swap to happen
2. they are basically two types of swaps  that Uniswap can perform - exact-input and exact-output

e.g. ETH/USDC pool. Alice wants to swap ETH for USDC.
exact input variant = sell 1 ETH for USDC
e.g. she's "exactly" specifying how much ETH to sell, but not specifying how USDC to get back.

exact out variant = sell up to 1 ETH for exactly 1500 USDC
e.g. she is "exactly" specifying how much ETH to sell and only a upper limit on how much ETH she's willing to spend

---

the "BalanceDelta" thing we have in the `afterSwap` becomes  very crucial to our use case
Because `BalanceDelta` => the exact amount of tokens that needs to be transferred (how much ETH was spent, how much TOKEN to withdraw)

Tl;DR: we gotta use `afterSwap` because we do not know how much ETH Alice spent before the swap happens 


### minting points

maybe we can use 'tx.origin', is that true?

if Alice is using an account abstracted wallet (SC wallet)

'tx.origin' = address of the relayer

GENERAL PURPOSE: 'tx.origin' doesnt work either

how tf do we figure out who to mint points to

we're gonna ask the user to give us an address to mint points to (optionally)

if they dont specify an address/invalid address = dont mint any points

#### hookData

hookData allows users to pass in arbitrary information meant for use by the hook contract

Alice -> Router.swap(...., hookData) -> PoolManager.swap(...., hookData) -> HookContract.before..(..., hookData)

the hook contract can figure out what it wants to do with that hookData

in our case, we're gonna use this as a way to ask the user for an address

to illustrate the concept a bit better, a couple examples of better ways to use hookData

e.g. KYC hook for example
verify a ZK Proof that somebody is actually a verified human (World App ZK Proof)
hook only lets you swap/become an LP if youre a human

ZK Proof => hookData

ZK Proof => hookData

#### BalanceDelta

effectively, for all intents and purposes, you can think of BalanceDelta as a struct with two values

```
struct BalanceDelta {
    int128 amount0;
    int128 amount1;
}
```

for a given operation (e.g. a swap) the related `BalanceDelta` contains amounts of token0 and token1 that need to be moved around

`amount0` => amount of token0
`amount1` => amount of token1

NOTE: these amounts are `int`s and NOT `uint`s
i.e. these can be negative numbers

in fact, in case of a swap, one of them will always be a negative number

there's a convention that's followed in uniswap

where everytime we talk about "money changing hands", we represent money coming in to uniswap and money going out of uniswap based on the sign of the numeric value

this "direction" of a token transfer is represented from the perspective of the caller to uniswap

+ve number => money is coming in to user's wallet (i.e. money is leaving Uniswap)
-ve number => money is leaving user's wallet (i.e. money is entering Uniswap)

in the case of a Swap where youre exchanging one token for another

imagine ETH/USDC pool, selling ETH for USDC, ETH is token0, USDC is token1

```
BalanceDelta {
    amount0 = some negative number (amount of ETH being swapped),
    amount1 = some positive number (amount of USDC being swapped)
}
```

in the case of Adding Liquidity to a pool,

(under the asumption you are adding both tokens as liquidity)

amount0 = -ve
amount1 = -ve