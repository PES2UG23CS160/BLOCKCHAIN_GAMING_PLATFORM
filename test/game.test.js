const Game = artifacts.require("Game");

contract("Game", (accounts) => {
  const owner = accounts[0];
  const player1 = accounts[1];
  const player2 = accounts[2];

  let game;

  beforeEach(async () => {
    game = await Game.new({ from: owner });
  });

  it("registers a player", async () => {
    await game.registerPlayer({ from: player1 });
    const { registered, score } = await game.getPlayer(player1);
    assert.equal(registered, true);
    assert.equal(score.toString(), "0");
  });

  it("mints an asset to a registered player", async () => {
    await game.registerPlayer({ from: player1 });
    const tx = await game.mintAsset(player1, "Sword", 2, { from: owner });
    const event = tx.logs.find(l => l.event === "AssetMinted");
    assert.equal(event.args.name, "Sword");
    assert.equal(event.args.rarity.toString(), "2");
  });

  it("updates player score", async () => {
    await game.registerPlayer({ from: player1 });
    await game.updateScore(player1, 500, { from: owner });
    const { score } = await game.getPlayer(player1);
    assert.equal(score.toString(), "500");
  });

  it("transfers asset between registered players", async () => {
    await game.registerPlayer({ from: player1 });
    await game.registerPlayer({ from: player2 });
    const tx = await game.mintAsset(player1, "Shield", 1, { from: owner });
    const tokenId = tx.logs.find(l => l.event === "AssetMinted").args.tokenId;
    await game.transferAsset(tokenId, player2, { from: player1 });
    const asset = await game.getAsset(tokenId);
    assert.equal(asset.owner, player2);
  });
});