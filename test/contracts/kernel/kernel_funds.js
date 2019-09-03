const { assertRevert } = require('../../helpers/assertThrow')
const { onlyIf } = require('../../helpers/onlyIf')
const { getBalance } = require('../../helpers/web3')

const ACL = artifacts.require('ACL')
const Kernel = artifacts.require('Kernel')
const KernelProxy = artifacts.require('KernelProxy')

const SEND_ETH_GAS = 31000 // 21k base tx cost + 10k limit on depositable proxies

contract('Kernel funds', ([permissionsRoot]) => {
  let aclBase

  // Initial setup
  before(async () => {
    aclBase = await ACL.new()
  })

  context(`> Kernel`, () => {
    // Test both the base itself and the KernelProxy to make sure their behaviours are the same
    for (const kernelType of ['Base', 'Proxy']) {
      context(`> ${kernelType}`, () => {
        let kernelBase, kernel

        before(async () => {
          if (kernelType === 'Proxy') {
            // We can reuse the same kernel base for the proxies
            kernelBase = await Kernel.new(true) // petrify immediately
          }
        })

        beforeEach(async () => {
          if (kernelType === 'Base') {
            kernel = await Kernel.new(false) // don't petrify so it can be used
          } else if (kernelType === 'Proxy') {
            kernel = Kernel.at((await KernelProxy.new(kernelBase.address)).address)
          }
        })

        it('cannot receive ETH', async () => {
          // Before initialization
          assert.isFalse(await kernel.hasInitialized(), 'should not have been initialized')

          await assertRevert(kernel.sendTransaction({ value: 1, gas: SEND_ETH_GAS }))

          // After initialization
          await kernel.initialize(aclBase.address, permissionsRoot)
          assert.isTrue(await kernel.hasInitialized(), 'should have been initialized')

          await assertRevert(kernel.sendTransaction({ value: 1, gas: SEND_ETH_GAS }))
        })
      })
    }
  })
})
