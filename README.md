### Remaining challenge:
> newImplementation.call(msg.data) --> use msg.data/TX to make this initialization


# PROXIES:
- 2 main different type depending on where the upgradeability mechanism resides: UUPS vs Transparent
- Use of EIP1967 to avoid storage clash (alternatively, extend implementation storage when upgrading instead of changing its storage layout) 
- Use an "admin" functionality to avoid function clash: to delegate or to not delegate
 
REMAINING QUESTIONS:
- If a contract is OpenZeppelin Upgradeable what happens? What type of proxy becomes? Review OwnableUpgradeable
- How OZ _gap requirement for Upgradeability compliance fits here?
- If constructors don't work, why is it required the disableInitializers? They work in the implementation but do not work on the proxy, which stores variables
- Initialization of base contract when inheriting OZ upgradeble contracts? Must call initialize() functions of contracts that inherit
- What happens with constant/immutable variables in implementations? They work 
- In clones, how is storage configured if it's only delegatecalling?


# Transparent vs UUPS proxies:
The difference is in how the upgradeability is performed --> Proxy or Implementation

## TRANSPARENT PROXY: 
- Upgrade logic managed in proxy
- Require an admin mechanism to decide if a call should be executed in proxy or delegated
  
## UUPS PROXY:
- Upgrade logic managed in implementation --> solidity compiler will complain if there is function selector clash
- Can be implemented by simply inheriting a common standard interface that includes upgradeability like OZ's UUPSUpgradeable interface
- Not including an upgradeability mechanism will lock the contract forever


# OTHER TYPES OF PROXIES: 
## DIAMOND PROXY:
 - Proxys stores a mapping from fSelector => implementation address
 - Allows going over max contract size
 - More granular upgrades
 - Storage clashes between implementations --> variant of EIP1967 where each implementation storage is defined as a struct and stored using EIP1967

## BEACON:
 - Multiple proxies per implementation
 - Each proxy stores the address of a beacon (instead of implementation), that holds the implementation address
 - When the proxy receives the call, it asks the beacon which implementation to use
 - Proxies don't need to keep their storage (no need for EIP1967)

## CLONE or MINIMAL PROXY:
 - Factory-like pattern to create several proxies that simply delegateCall to the same Implementation
 - Based on EIP1167
 - They are not upgradeable, thus don't need storage or management functions

## METAMORPHIC CONTRACTS:
 - Preserves the contract address among upgrades, but not its state
 - Relies on the CREATE2 opcode introduced in EIP1014
 - A contract address deployed using CREATE2 is determined by the contract deployment code, the sender and a salt
 - Requires the selfdestruct opcode to clean the contract address to be updated
 - seldestruct does not delete the contract until the end of the TX --> 2TXs are required to update the contract (one to destroy the old contract and another to deploy the new contract), introducing a downtime
 - Does not require a Proxy or to change the constructor into an initializer