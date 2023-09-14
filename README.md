# Werewolf and witch Aptos move Item generator
- Item management and item generator by move smart contract
- Used in Werewolf and witch NFT War game [werewolfandwitch.xyz](https://werewolfandwitch.xyz/)
- Change the ```item_material_creator``` and ```item_creator``` in the ```Move.toml``` once you’ve initialized them with init functions

## Cloning the repository
```git clone https://github.com/werewolfandwitch/aptos-game-item-generator.git```
Change the file path in dependencies and update the addresses

## Initialize
Initialize with ```aptos init``` in the ```aptos-game-item-generator``` folder you just cloned

## Compile
```aptos move compile --named-addresses item_gen=default```

## Publish
```aptos move publish --named-addresses item_gen=default```




License
=======

    Copyright 2023 Werewolf and Witch

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.


