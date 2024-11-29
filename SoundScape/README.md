# SoundScape Collective - Generative Music NFT Platform

SoundScape Collective is a decentralized platform built on the Stacks blockchain that allows artists to contribute musical elements and collaborate in the creation of unique, generative music NFTs. The contract enables musicians to upload their creations as modular elements (melodies, harmonies, rhythms, and effects), which are then combined algorithmically to generate compositions. These compositions are minted as NFTs, with royalties distributed to contributors based on their elements used in the final composition.

Artists can mint new NFTs by contributing musical elements, and buyers can purchase unique generative music NFTs that represent a composition generated from a random selection of these elements.

## Key Features

- **Artist Contributions**: Musicians can contribute musical elements (e.g., melody, harmony, rhythm, effects) to the platform. Each element has attributes such as genre, mood, BPM, key, and rarity.
- **Generative Music Composition**: Using a random selection mechanism, the contract generates compositions by combining various elements. Each composition consists of four elements: melody, harmony, rhythm, and effects.
- **NFT Minting**: Users can mint generative music NFTs, each representing a unique composition. The minting price is fixed, and a maximum supply limit is enforced to ensure scarcity.
- **Royalties for Artists**: Contributors receive royalties from the sale of NFTs based on the elements they contributed. The royalty percentage is configurable.
- **Supply Management**: The contract owner can configure the minting price and maximum supply of NFTs.

---

## Contract Structure

### Constants
- `contract-owner`: The principal address of the contract owner, who has administrative privileges.
- `err-owner-only`: Error thrown if a non-owner tries to access owner-only functions.
- `err-invalid-contributor`: Error thrown when a non-registered contributor tries to add musical elements.
- `err-not-found`: Error thrown when a requested composition is not found.
- `err-max-supply`: Error thrown if an attempt is made to exceed the maximum supply of NFTs.
- `err-invalid-payment`: Error thrown if the minting payment is invalid.
- `err-element-exists`: Error thrown if an element already exists for the same type.

### NFT Token
- **soundscape**: A non-fungible token (NFT) representing the generative music compositions. Each NFT is minted with a unique ID.

### Data Variables
- `last-token-id`: Tracks the last minted NFT's token ID.
- `max-supply`: The maximum number of NFTs that can be minted. Set by the contract owner.
- `mint-price`: The price (in STX) required to mint a new NFT.
- `artist-royalty-percent`: The percentage of the minting price that is allocated as royalties to the artist.
  
### Data Maps
- `contributors`: A map to track which artists have been added to the platform and are allowed to contribute elements.
- `musical-elements`: Stores individual musical elements contributed by artists, including metadata such as genre, mood, BPM, and key.
- `element-counts`: Tracks the number of elements added for each element type (e.g., melody, harmony, etc.).
- `compositions`: Stores the generated compositions, linking them to their unique NFT token IDs.
- `artist-royalties`: Tracks royalties owed to each artist.

---

## Functions

### Administrative Functions
- **set-mint-price(new-price uint)**: Allows the contract owner to set a new price for minting NFTs. Only the owner can execute this function.
- **set-max-supply(new-max uint)**: Allows the contract owner to set a new maximum supply of NFTs. Once the limit is reached, no more NFTs can be minted.
- **add-contributor(artist principal)**: Registers a new artist as a contributor who is allowed to add musical elements. Only the contract owner can call this function.

### Artist Contribution Functions
- **add-musical-element(element-type string-ascii 32, name string-ascii 64, genre string-ascii 32, mood string-ascii 32, bpm uint, key string-ascii 8, duration uint, rarity uint, uri string-ascii 256)**:
  - Artists contribute musical elements such as melody, harmony, rhythm, and effects. Each element has attributes that define its musical characteristics. The element is stored in the contract and can later be used in NFT compositions.
  - The element type (melody, harmony, rhythm, or effect) is specified along with the relevant attributes (e.g., genre, BPM, mood). The contract checks if the artist is a valid contributor before allowing the contribution.

### Generation Functions
- **get-random(seed uint, max uint)**: A private function that generates a random value based on the given seed and a maximum value (max). It uses SHA256 hashing to ensure unpredictability.
- **generate-composition(seed uint)**: A private function that generates a composition by randomly selecting one element from each category (melody, harmony, rhythm, and effects) based on the provided seed. The resulting composition is a set of element IDs and a timestamp.

### Minting Functions
- **mint()**: Allows a user to mint a new NFT representing a generative music composition. The function checks if the minting price is paid, ensures that the minting does not exceed the maximum supply, and mints the new NFT. After minting, the function also distributes royalties to contributing artists.
- **distribute-royalties(payment uint)**: A private function that calculates and distributes royalties to contributing artists based on the elements used in the generated composition. The percentage of royalties distributed is configurable.

### Getter Functions
- **get-composition(token-id uint)**: Retrieves the details of a specific composition by token ID.
- **get-musical-element(element-type string-ascii 32, element-id uint)**: Retrieves the details of a specific musical element (e.g., a melody or rhythm) by its element type and ID.
- **get-element-count(element-type string-ascii 32)**: Returns the number of elements of a given type (melody, harmony, etc.) that have been contributed to the platform.
- **get-composition-details(token-id uint)**: Retrieves detailed composition data for a specific NFT token ID, including the elements (melody, harmony, rhythm, effects), seed, and timestamp.
- **is-contributor(address principal)**: Checks if a given principal is registered as a contributor to the platform.
- **get-mint-price()**: Returns the current mint price for generating new NFTs.
- **get-max-supply()**: Returns the maximum supply of NFTs that can be minted.
- **get-current-supply()**: Returns the current number of minted NFTs.

---

## How to Use

1. **Register as a Contributor**: Only the contract owner can register new contributors. If you are an artist, you need to be added by the contract owner.
   
2. **Contribute Musical Elements**: Once registered, artists can contribute musical elements by calling the `add-musical-element` function, specifying the type, attributes, and metadata (URI).

3. **Mint an NFT**: To mint an NFT, the user must call the `mint()` function, paying the required mint price in STX. This will generate a unique composition and mint an NFT representing the generative music composition.

4. **Purchase an NFT**: Anyone can purchase a generative music NFT by paying the mint price. The NFT will contain a unique composition created by the combination of different musical elements contributed by artists.

5. **Receive Royalties**: Artists will receive royalties when their musical elements are used in the minting of new NFTs. The royalty percentage is configurable by the contract owner.

---

## Example Workflow

1. An artist contributes a melody by calling `add-musical-element` with the relevant details.
2. The artist registers themselves as a contributor using the `add-contributor` function.
3. Another artist contributes a harmony element.
4. A user mints an NFT by calling `mint()`, paying the required price.
5. The contract generates a composition using random selections of elements from melody, harmony, rhythm, and effects.
6. The NFT is minted and distributed to the user, with royalties paid to the contributing artists.

---

SoundScape Collective combines the creativity of musicians with the power of blockchain technology to create a platform for generative music NFTs. The contract ensures fair distribution of royalties, provides artists with an opportunity to monetize their contributions, and offers collectors unique, algorithmically generated compositions.

This decentralized approach to music creation enables a new form of artistic collaboration and digital ownership, bringing a fresh perspective to the NFT ecosystem.

--- 

## Future Enhancements

- **Enhanced Royalties Distribution**: Implementing a more sophisticated royalty distribution mechanism based on the specific elements used in each composition.
- **Dynamic Mint Pricing**: Introducing dynamic pricing models based on demand or rarity.
- **Expanded Element Types**: Allowing contributors to add new types of musical elements (e.g., vocals, instruments, sound effects).