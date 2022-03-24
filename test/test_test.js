// KlaytnGreeter 컨트랙트와 직접 상호작용
// const KlaytnGreeter = artifacts.require('./KlaytnGreeter.sol');
// const truffleAssert = require('truffle-assertions');

// contract('KlaytnGreeter', async (accounts) => {
//     // 컨트랙트 인스턴스를 상위 레벨에 저장해
//     // 모든 함수에서 접근할 수 있도록 합니다.
//     var klaytnGreeterInstance;
//     var owner = accounts[0];
//     var greetMsg = 'Hello, Klaytn';

//     // 각 테스트가 진행되기 전에 실행됩니다.
//     before(async function () {
//         // set contract instance into a variable
//         klaytnGreeterInstance = await KlaytnGreeter.new(greetMsg, {
//             from: owner
//         });
//     });

//     it('#1 check Greeting message', async function () {
//         // set the expected greeting message
//         var expectedGreeting = greetMsg;
//         var greet = await klaytnGreeterInstance.greet();
//         assert.equal(expectedGreeting, greet, 'greeting message should match');
//     });

//     it('#2 update greeting message.', async function () {
//         var newGreeting = 'Hi, Klaytn';

//         await klaytnGreeterInstance.setGreet(newGreeting, { from: owner });
//         var greet = await klaytnGreeterInstance.greet();
//         assert.equal(newGreeting, greet, 'greeting message should match');
//     });

//     it('#3 [Failure test] Only owner can change greeting.', async function () {
//         var fakeOwner = accounts[1];
//         await truffleAssert.fails(
//             klaytnGreeterInstance.setGreet(greetMsg, { from: fakeOwner })
//         );
//     });
// });
