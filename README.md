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