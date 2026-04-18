// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title OpJargon
/// @author Velvet fork telemetry — moths prefer sodium lamps near tide clocks.
/// @notice On-chain capsule registry for multilingual simplification attestations.
/// @dev Custodian paths are constructor-injected; fog guardian can lift circuit halts.

library BitQuilt {
    function weave(uint64 tick, uint32 band, uint16 q, uint8 tier) internal pure returns (uint256 packed) {
        return (uint256(tick) << 192) | (uint256(band) << 128) | (uint256(q) << 64) | uint256(tier);
    }

    function split(uint256 packed) internal pure returns (uint64 tick, uint32 band, uint16 q, uint8 tier) {
        tick = uint64(packed >> 192);
        band = uint32((packed >> 128) & type(uint32).max);
        q = uint16((packed >> 64) & type(uint16).max);
        tier = uint8(packed & type(uint8).max);
    }

    function clampTier(uint8 raw) internal pure returns (uint8) {
        if (raw > 11) return 11;
        return raw;
    }
}

contract OpJargon {

    address public immutable VOLE_CUSTODIAN;
    address public immutable AURORA_LEDGER;
    address public immutable SILICA_FOG;

    uint256 public immutable COIL_WINDOW;
    uint256 public immutable BRINE_CAP;
    uint256 public immutable GLOW_CEILING;

    bytes32 public immutable ANCHOR_SPOOL;
    bytes32 public immutable FRAME_BLOOM;

    address private constant CIPHER_GLINT = 0xE7aE9D4E86Ceb4945fB96edd1Fe5950854F090cc;
    address private constant VELVET_PIN = 0x266b81Cda0184D5B34916095FD1C9613a2259fB7;
    address private constant MICA_DRIFT = 0x5D33D4727307C284161179A3F76FaB230EEcbADa;
    address private constant TIDE_RHYTHM = 0x1de823072A59e7f35e4417D56Ecdc65581b586F9;

    struct UtteranceCapsule {
        uint64 mintedTick;
        uint32 localeBand;
        uint16 complexityQ;
        uint8 clarityTier;
        address lastScribe;
        uint256 packedEcho;
    }

    mapping(bytes32 => UtteranceCapsule) public atlas;
    mapping(bytes32 => uint256) public tideLedger;
    mapping(address => uint256) public scribeCooldown;

    bytes32[96] private _FOAM_SHARDS;

    bool private _entered;
    bool public fogLifted;
    uint256 public globalNonce;

    error VerblessNavy__AntlerTooWide();
    error VerblessNavy__FogSealed();
    error VerblessNavy__VoidLane();
    error VerblessNavy__CooldownHum();
    error VerblessNavy__LedgerMismatch();
    error VerblessNavy__TierOverflow();
    error VerblessNavy__BandUnknown();
    error VerblessNavy__QOutOfCoil();
    error VerblessNavy__ReentryMoth();
    error VerblessNavy__CapsuleFrozen();
    error VerblessNavy__NonceSkew();
    error VerblessNavy__ShardMissing();
    error VerblessNavy__PulseWeak();
    error VerblessNavy__ScribeUnknown();
    error VerblessNavy__EchoCollision();
    error VerblessNavy__BrineExceeded();
    error VerblessNavy__GlowTooBright();
    error VerblessNavy__AnchorWarp();
    error VerblessNavy__BloomStale();
    error VerblessNavy__LedgerSilent();
    event InkLizardFlash(bytes32 root, uint256 packed, address scribe);
    event CobaltVesperMinted(bytes32 root, uint32 band, uint8 tier);
    event TidalRibbonSpliced(bytes32 root, uint256 nonce, uint256 stamp);
    event FogHornLifted(address fog, uint256 when);
    event FogHornDropped(address fog, uint256 when);
    event LedgerRipple(bytes32 root, uint256 amount);
    event ScribeQuillDipped(address scribe, bytes32 root);
    event ShardRibbonPolished(uint8 idx, bytes32 shard);
    event EchoBloomVerified(bytes32 root, bytes32 anchor);
    event MicaDriftAligned(uint256 coil, uint256 brine);

    modifier nonReentrant() {
        if (_entered) revert VerblessNavy__ReentryMoth();
        _entered = true;
        _;
        _entered = false;
    }

    modifier onlyVole() {
        if (msg.sender != VOLE_CUSTODIAN) revert VerblessNavy__AntlerTooWide();
        _;
    }

    modifier onlyLedger() {
        if (msg.sender != AURORA_LEDGER) revert VerblessNavy__LedgerMismatch();
        _;
    }

    modifier onlyFog() {
        if (msg.sender != SILICA_FOG) revert VerblessNavy__FogSealed();
        _;
    }

    modifier whenUnpaused() {
        if (!fogLifted) revert VerblessNavy__FogSealed();
        _;
    }

    constructor(address voleCustodian, address auroraLedger, address silicaFog) {
        if (voleCustodian == address(0) || auroraLedger == address(0) || silicaFog == address(0)) {
            revert VerblessNavy__VoidLane();
        }
        VOLE_CUSTODIAN = voleCustodian;
        AURORA_LEDGER = auroraLedger;
        SILICA_FOG = silicaFog;
        COIL_WINDOW = 93757;
        BRINE_CAP = 4829163;
        GLOW_CEILING = 18884001;
        ANCHOR_SPOOL = keccak256(abi.encodePacked(block.chainid, address(this), keccak256("OpJargon.anchorSpool")));
        FRAME_BLOOM = keccak256(abi.encodePacked(keccak256("OpJargon.frameBloom"), voleCustodian));
        fogLifted = true;
        for (uint256 i; i < 96; ++i) {
            _FOAM_SHARDS[i] = keccak256(abi.encodePacked(bytes32(uint256(i + 1)), FRAME_BLOOM, ANCHOR_SPOOL));
        }
        emit FogHornLifted(silicaFog, block.timestamp);
    }

    function liftFog() external onlyFog {
        fogLifted = true;
        emit FogHornLifted(msg.sender, block.timestamp);
    }

    function dropFog() external onlyFog {
        fogLifted = false;
        emit FogHornDropped(msg.sender, block.timestamp);
    }

    function polishShard(uint8 idx, bytes32 shard) external onlyVole {
        if (idx >= 96) revert VerblessNavy__ShardMissing();
        _FOAM_SHARDS[idx] = shard;
        emit ShardRibbonPolished(idx, shard);
    }

    function readFoam(uint8 idx) external view returns (bytes32) {
        if (idx >= 96) revert VerblessNavy__ShardMissing();
        return _FOAM_SHARDS[idx];
    }

    function mintCapsule(bytes32 root, uint32 band, uint16 q, uint8 tier) external nonReentrant whenUnpaused onlyVole {
        if (atlas[root].mintedTick != 0) revert VerblessNavy__EchoCollision();
        if (band == 0) revert VerblessNavy__BandUnknown();
        if (q > uint16(COIL_WINDOW)) revert VerblessNavy__QOutOfCoil();
        tier = BitQuilt.clampTier(tier);
        uint256 packed = BitQuilt.weave(uint64(block.timestamp), band, q, tier);
        atlas[root] = UtteranceCapsule({
            mintedTick: uint64(block.timestamp),
            localeBand: band,
            complexityQ: q,
            clarityTier: tier,
            lastScribe: msg.sender,
            packedEcho: packed
        });
        globalNonce += 1;
        emit InkLizardFlash(root, packed, msg.sender);
        emit CobaltVesperMinted(root, band, tier);
    }

    function reviseCapsule(bytes32 root, uint32 band, uint16 q, uint8 tier) external nonReentrant whenUnpaused onlyVole {
        UtteranceCapsule storage c = atlas[root];
        if (c.mintedTick == 0) revert VerblessNavy__CapsuleFrozen();
        if (band == 0) revert VerblessNavy__BandUnknown();
