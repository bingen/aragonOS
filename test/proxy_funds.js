const { assertRevert } = require('./helpers/assertThrow')
const { getBalance } = require('./helpers/web3')
const { hash } = require('eth-ens-namehash')

const Kernel = artifacts.require('Kernel')
const AppProxyUpgradeable = artifacts.require('AppProxyUpgradeable')
const AppStub = artifacts.require('AppStub')
const DAOFactory = artifacts.require('DAOFactory')
const ACL = artifacts.require('ACL')

const getContract = artifacts.require

const keccak256 = require('js-sha3').keccak_256
const APP_BASE_NAMESPACE = '0x'+keccak256('base')

contract('Proxy funds', accounts => {
  let factory, acl, kernel, app, appCode, appProxy, vault

  const permissionsRoot = accounts[0]
  const appId = hash('stub.aragonpm.test')
  const zeroAddr = '0x0000000000000000000000000000000000000000'
  let ETH

  before(async () => {
    const kernelBase = await getContract('Kernel').new()
    ETH = await kernelBase.ETH()
    const aclBase = await getContract('ACL').new()
    factory = await DAOFactory.new(kernelBase.address, aclBase.address, '0x00')

    appCode = await AppStub.new()

    const receipt = await factory.newDAO(permissionsRoot)
    const kernelAddress = receipt.logs.filter(l => l.event == 'DeployDAO')[0].args.dao

    kernel = Kernel.at(kernelAddress)
    acl = ACL.at(await kernel.acl())

    const r = await kernel.APP_MANAGER_ROLE()
    await acl.createPermission(permissionsRoot, kernel.address, r, permissionsRoot)

    // app
    await kernel.setApp(APP_BASE_NAMESPACE, appId, appCode.address)
    const initializationPayload = appCode.contract.initialize.getData()
    appProxy = await AppProxyUpgradeable.new(kernel.address, appId, initializationPayload, { gas: 5e6 })
    app = AppStub.at(appProxy.address)
    // vault
    vault = await getContract('VaultMock').new()
    const vaultId = hash('vault.aragonpm.test')
    await kernel.setApp(APP_BASE_NAMESPACE, vaultId, vault.address)
    await kernel.setDefaultVaultId(APP_BASE_NAMESPACE, vaultId)
  })

  it('recovers ETH', async() => {
    const amount = 1
    const initialAppBalance = await getBalance(appProxy.address)
    const initialVaultBalance = await getBalance(vault.address)
    const r = await appProxy.sendTransaction({ value: 1, gas: 25000 })
    assert.equal((await getBalance(appProxy.address)).valueOf(), initialAppBalance.plus(amount))
    await appProxy.transferToVault(ETH)
    assert.equal((await getBalance(appProxy.address)).valueOf(), 0)
    assert.equal((await getBalance(vault.address)).valueOf(), initialVaultBalance.plus(initialAppBalance).plus(amount).valueOf())
  })

  it('recovers tokens', async () => {
    const amount = 1
    const token = await getContract('StandardTokenMock').new(accounts[0], 1000)
    const initialAppBalance = await token.balanceOf(appProxy.address)
    const initialVaultBalance = await token.balanceOf(vault.address)
    await token.transfer(appProxy.address, amount)
    assert.equal((await token.balanceOf(appProxy.address)).valueOf(), initialAppBalance.plus(amount))
    await appProxy.transferToVault(token.address)
    assert.equal((await token.balanceOf(appProxy.address)).valueOf(), 0)
    assert.equal((await token.balanceOf(vault.address)).valueOf(), initialVaultBalance.plus(initialAppBalance).plus(amount).valueOf())
  })

  it('fails if vault is not contract', async() => {
    const amount = 1
    const vaultId = hash('vault.aragonpm.test')
    const initialAppBalance = await getBalance(appProxy.address)
    await kernel.setApp(APP_BASE_NAMESPACE, vaultId, '0x0')
    const r = await appProxy.sendTransaction({ value: 1, gas: 25000 })
    assert.equal((await getBalance(appProxy.address)).valueOf(), initialAppBalance.plus(amount))
    return assertRevert(async () => {
      await appProxy.transferToVault(ETH)
    })
  })

})
