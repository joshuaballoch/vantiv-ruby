Vantiv Ruby Changes

0.2.0
-----------

NOTE: API change occurs in this version bump on:

1. `Vantiv.auth` and `Vantiv.auth_capture` now require `expiry_month`
   and `expiry_year` to be passed. Merchants are responsible for persisting
   this data.
2. `Vantiv.credit`'s `amount` argument is now optional.

- Send expiration data on live transactions
  - Major miscommunication from Vantiv during development that sending
    expiration data on authorizations and auth_captures (Sale) was
    not necessary.
  - Expiration data is required for card-not-present transactions
  - In actuality, majority of transactions will work without expiry
    data but a significant number of them will fail with "Invalid Transaction"
    and "Do No Honor" response codes.
- Make amount in credit endpoint optional; with no amount passed, Vantiv
  credits full amount of original transaction
- Strip non-numeric characters from credit card numbers:
  - Numbers input with spaces or delimeters are acceptable for direct
    tokenization as a result
- Cast arguments accepted to strings in Request Bodies
- Retry requests when Vantiv doesn't respond with JSON
  - Sometimes, Vantiv's API doesn't respond with JSON (typically, when
    a service is down or something)
  - It seems safe to retry requests in that case, up to 3 times.
- Add mocked sandbox responses for all other endpoints:
  - Auth
  - Capture
  - Auth Reversal
  - Credit
  - Refund
  - Void

0.1.0
-----------

- Add a mocked sandbox structure for gem to operate in test:
  - Allows gem to operate in a test environment without making real
    network requests, while still behaving identically to certification
    Environment
  - Only difference is that mocked sandbox has consistent payment account
    IDs per card number, available on TestCard object
    #mocked_sandbox_payment_account_id
  - Intially only for direct tokenization endpoint
- Implement direct tokenization, allowing merchants to both use eProtect or
  tokenize with Vantiv directly.
- Implement auth reversal
- Implement refunds
- Implement credits
- Implement voids
- Add TravisCI for CI
- Add paypage server and paypage driver, objects to run a basic version of
  an eProtect page. Enables retrieving paypageRegistrationIDs in order to test
  usage to tokenize via eProtect.
- Add script to run all Devhub certification environment validation tests
  via script:
  - Allows merchants to install gem and certify quickly, rather than manually


