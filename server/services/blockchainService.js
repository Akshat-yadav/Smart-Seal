const { ethers } = require('ethers');

const CONTRACT_ABI = [
  'function addCertificate(bytes32 hash) external',
  'function verifyCertificate(bytes32 hash) external view returns (bool)'
];

const isBlockchainEnabled = () => {
  return Boolean(
    process.env.BLOCKCHAIN_RPC_URL &&
      process.env.BLOCKCHAIN_CONTRACT_ADDRESS &&
      process.env.BLOCKCHAIN_ADMIN_PRIVATE_KEY
  );
};

const getContract = async () => {
  const provider = new ethers.JsonRpcProvider(process.env.BLOCKCHAIN_RPC_URL);
  const wallet = new ethers.Wallet(process.env.BLOCKCHAIN_ADMIN_PRIVATE_KEY, provider);
  const contract = new ethers.Contract(
    process.env.BLOCKCHAIN_CONTRACT_ADDRESS,
    CONTRACT_ABI,
    wallet
  );
  const network = await provider.getNetwork();

  return { contract, chainId: network.chainId.toString() };
};

const toBytes32Hash = (hexHash) => {
  const normalized = hexHash.startsWith('0x') ? hexHash : `0x${hexHash}`;
  if (!/^0x[0-9a-fA-F]{64}$/.test(normalized)) {
    throw new Error('Invalid SHA256 hash format for blockchain write');
  }
  return normalized;
};

const storeHashOnChain = async (hexHash) => {
  if (!isBlockchainEnabled()) {
    return { enabled: false, stored: false, txHash: null, error: null, chainId: null };
  }

  try {
    const { contract, chainId } = await getContract();
    const tx = await contract.addCertificate(toBytes32Hash(hexHash));
    const receipt = await tx.wait();
    return {
      enabled: true,
      stored: receipt?.status === 1,
      txHash: tx.hash,
      error: null,
      chainId
    };
  } catch (error) {
    return {
      enabled: true,
      stored: false,
      txHash: null,
      error: error.message,
      chainId: null
    };
  }
};

const verifyHashOnChain = async (hexHash) => {
  if (!isBlockchainEnabled()) {
    return { enabled: false, isValid: null, error: null };
  }

  try {
    const { contract, chainId } = await getContract();
    const isValid = await contract.verifyCertificate(toBytes32Hash(hexHash));
    return {
      enabled: true,
      isValid: Boolean(isValid),
      chainId,
      error: null
    };
  } catch (error) {
    return {
      enabled: true,
      isValid: null,
      chainId: null,
      error: error.message
    };
  }
};

module.exports = {
  isBlockchainEnabled,
  storeHashOnChain,
  verifyHashOnChain
};