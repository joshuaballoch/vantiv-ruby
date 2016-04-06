# Vantiv Ruby Client
[![Build Status](https://travis-ci.org/plated/vantiv-ruby.svg)](https://travis-ci.org/plated/vantiv-ruby)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vantiv'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vantiv

## Configuration

The gem needs the following configuration to be set on app initialization. It is highly recommended that you do not commit sensitive data into version control, but instead use environment variables.

```ruby
Vantiv.configure do |config|
  config.license_id = ENV["VANTIV_LICENSE_ID"]
  config.acceptor_id = ENV["VANTIV_ACCEPTOR_ID"]
  config.order_source = "desired-order-source"
  config.paypage_id = ENV["VANTIV_PAYPAGE_ID"]

  config.default_report_group = 'default-report-group'
end
```

## Certification

Vantiv's DevHub requires merchants to certify their applications for usage with their API. To make this integration process easy, the gem provides a script to run through these tests.

To certify your application, run the following script:

```
$ LICENSE_ID=sub-your-license-id-in-here ACCEPTOR_ID=sub-your-acceptor-id-in-here PAYPAGE_ID=your-paypage-id vantiv-certify-app
```

A certs.txt file will be generated in the directory that the script is run, and then opened. It contains a list of DevHub Certification test names and associated Request IDs, like follows:

```
L_AC_1, request-id-for-L_AC_1-here
L_AC_2, request-id-for-L_AC_2-here
```

Navigate to your application's page in DevHub's developer portal (apideveloper.vantiv.com). Paste the contents of this file into the validation form input field, and then click "Validate".

## Usage

The vantiv gem provides a simple ruby client for interacting with Vantiv's DevHub API. This API wraps their Litle/XML API and provides an API that uses json. This gem provides a way for a merchant to:

1. Use Vantiv's eProtect feature to tokenize sensitive card information directly to Vantiv's servers.
2. Run the following transactions on customers' accounts:

  1. Authorizations (Vantiv.auth)
  2. Authorization reversals (Vantiv.auth_reversal)
  3. Capturing authorizations (Vantiv.capture)
  4. Direct authorization-and-captures (sales) (Vantiv.auth_capture)
  5. Credits (Vantiv.credit)
  6. Voids (Vantiv.void)
  7. Refunds (Vantiv.refund)

Please note that this gem only provides a structure for integrating with Vantiv in a structure where the merchant never handles sensitive card data. This enables merchants to seek a simpler PCI compliance level. As such, placing transactions via this ruby client requires the merchant to first tokenize cardholder data via Vantiv's eProtect feature (supported).

### Tokenizing via eProtect

This gem provides a structure for tokenizing client payment information via Vantiv's eProtect feature. The basic structure for tokenizing via eProtect are:

1. Customer submits their payment information via a Vantiv iframe element.
2. The iframe element returns a temporary token (Paypage Registration ID).
3. The page submits the temporary token to the merchant server.
4. The merchant server submits the temporary token to Vantiv, and receives a PaymentAccountID to store for future transactions.

#### Obtaining a Paypage Registration ID

To submit client card data and retrieve a temporary token from Vantiv, the merchant needs to add the Vantiv payframe to a form where a user inputs their payment information. The payframe renders, within an iframe, four fields:

1. Card number
2. Expiry Month
3. Expiry Year
4. CVV

Other information, like billing address information, cardholder name, and others are rendered by the merchant's pay page and passed to the iframe as it submits card data.

To render the payframe, the merchant must include the payframe js file in the page and then initialize it like so:

```
# html.erb example
<script src="<%= Vantiv.payframe_js %>" type="text/javascript"></script>
# OR:
<%= javascript_include_tag Vantiv.payframe_js %>
# OR it can be hardcoded:
<script src="https://request-prelive.np-securepaypage-litle.com/LitlePayPage/js/payframe-client.min.js" type="text/javascript"></script>
```

To initialize the payframe:
```js
// Create a callback to pass to the payframe, which is called
// after the payframe submits and receives a response from Vantiv
var payframeClientCallback = function(response) {
  if (response.response !== '870') {
    // Then an error occurred.
    // The response may have one of a few error codes plus a human readable message
    // The merchant can decide what to do in this case
    console.log(response.message);
  } else {
    // Then the temporary token has been retrieved, and the merchant can submit it
    // to the merchant's servers to retrieve the PaymentAccountID
    console.log(response.paypageRegistrationId);
  }
}

// Initialize a Payframe client, which has many options
var client = new LitlePayframeClient({
  "paypageId": "<%= Vantiv.paypage_id %>",
  "style":"sample2",
  "height":"250",
  "reportGroup":"IFrame Sample",
  "timeout":"60000",
  "div": "payframe", // this references the ID of the element in which you want the payframe to render
  "callback": payframeClientCallback,
  "showCvv": true,
  "months": {
    "1":"January",
    "2":"February",
    "3":"March",
    "4":"April",
    "5":"May",
    "6":"June",
    "7":"July",
    "8":"August",
    "9":"September",
    "10":"October",
    "11":"November",
    "12":"December"
  },
  "numYears": 8,
  "tooltipText": "A CVV is the 3 digit code on the back of your Visa, MasterCard and Discover or a 4 digit code on the front of your American Express",
  "tabIndex": {
    "cvv":4,
    "accountNumber":1,
    "expMonth":2,
    "expYear":3
  },
  "placeholderText": {
    "cvv":"CVV",
    "accountNumber":"Account Number"
  }
});

// Now with a client initialize, the merchant is responsible for interrupting form submission
// in whatever way it wants (this is only an example), getting the temporary token, and
// then proceeding as it wishes.
window.onFormSubmit = function(){
  client.getPaypageRegistrationId({
    "id": "customer-id?",
    "orderId": "someOrderID"
  });

  return false;
}
```

The above example shows the basic mechanics of rendering and interacting with the payframe.

TODO: add more infor on payframe error codes here

Once the temporary token has been retrieved, it should be posted to the merchant server, where the gem can be used to retrieved the permanent token (PaymentAccountID).

#### Retrieving a Payment Account ID

In the server, once a temporary token has been received, a permanent token can be retrieved. To do so, use the `tokenize` method:

```ruby
Vantiv.tokenize(temporary_token: 'temporary-token-here')
```

This will return a TokenizationResponse object, which responds to `success?` and `failure?`, and which returns the `payment_account_id` retrieved from Vantiv. The merchant should save this token for use on future transactions.

NOTES: There are a few gotchas with tokenization, namely:

1. PaymentAccountIDs in Vantiv are unique to the card information. If a merchant has two users using the same card info, it may end up retrieving the same PaymentAccountID for both clients. Depending on how the merchant runs its reporting/attribution, this may be a concern to look into.
2. The process of tokenization does not provide any assurance on the validity of a cardholder's account. An auth can be used to check this validity.

### Authorizations

Authorizations enable a merchant to confirm the validity of a submitted payment method and place a hold on funds for a purchase of goods or services from a merchant. They last from 7-30 days, depending on the payment type:

| Network  | Auth Lifespan |
| ------------- | ------------- |
| Amex  | 7 days  |
| Discover  | 10 days  |
| Mastercard  | 7 days  |
| Paypal  | 29 days (Vantiv recommends 3 days max)  |
| Paypal Credit  | 30 days  |
| Visa  | 7 days  |

To place an authorization on a client's card, simply do:

```ruby
Vantiv.auth(
  payment_account_id: '12345', # retrieved earlier
  amount: 10000, # amount in cents, as an integer
  customer_id: '123',
  external_id: 'order123'
)

```

Notes:

1. See Tokenizing via eProtect for notes on how to retrieve a payment account id.
2. Customer ID and Order ID are reference data required for placing authorizations and auth_captures in Vantiv's system. The merchant can choose what reference data to put in here; they only need to exist.

### Authorization Reversals

Authorization reversals allow a merchant to remove a hold on a client's credit card, freeing up funds to use on other purchases. Authorization reversals can reverse the full amount of an authorization, or the remaining balance after a partial capture of an authorization.
Amount must be less than the amount authorized.

```ruby
Vantiv.auth_reversal(
  transaction_id: 'transaction-id-from-auth', # retrieved earlier
  amount: 10000, # amount in cents, as an integer. must be less than or equal to auth amount.
)

```

### Capturing Authorizations

Captures enable a merchant to charge a customer funds previously placed under an authorization. To place a capture, simply do:

```ruby
Vantiv.capture(transaction_id: 'transaction-id-from-auth')
```

The above captures the full amount placed on hold via a previous authorization.

It is possible for a merchant to capture an amount differing from the amount placed on the authorization. Use cases for this typically consist of orders that are fulfilled in steps, for examples multiple shipments, or services for which the final charge is not determined at the point of authorization, like restaurants / tips. To perform a partial capture, simply pass the optional amount argument to the capture:

```ruby
Vantiv.capture(
  transaction_id: 'transaction-id-from-auth',
  amount: 10000 #amount in cents
)
```

It is possible to capture an amount exceeding the amount authorized, there are some restrictions that may vary from network to network on how much it can be exceeded by. It is recommended not to do so without consulting Vantiv or other relevant groups.

### Auth capture (sales)

TODO: Add usage info

### Credits

Vantiv's Credit transaction enables a merchant to refund customers money against the following transactions:

1. Capture Transactions
2. Sale Transactions

To perform a credit, simply:

```ruby
Vantiv.credit(
  transaction_id: 'transaction-id-from-prior-transaction',
  amount: 10000 #amount to refund in cents
)
```

NOTE: Vantiv does NOT provide any transaction checking when a request is received to credit a customer. This includes even not checking that the prior transaction _even exists_. See 'Tied Transaction Error Handling' for more info.

### Voids

> The Void transaction enables you to cancel any settlement transaction as long as the transaction has not yet settled and the original transaction occurred within the system.
> Do not use Void transactions to void an Authorization. To remove an Authorization use an Authorization reversal transaction.

TODO: Add usage info

### Refunds

TODO: Add usage info

## Usage in non-production environments

To use the gem in any non-production environment, set the client's environment to the certification environment.

```ruby
Vantiv.configure do |config|
  config.environment = Vantiv::Environment::CERTIFICATION
end
```

This directs the gem to make API requests to Vantiv's pre-live, certification environment. Transactions made in this environment behave like in production, but do not result in any charges going through.

Vantiv provides a whitelist of card numbers that lead to certain types of behaviour that merchants may wish to enact when developing their applications.

The gem provides a simple `Vantiv::TestCard` class for users' convenience. For example, Vantiv's whitelist includes a Visa card that maps to a 'valid account' - one for which all auths / charges will process successfully. This info can be accessed via `Vantiv::TestCard`, which returns an object with all of the card info needed:

```ruby
card = Vantiv::TestCard.valid_account
card.card_number
card.cvv
card.expiry_month
card.expiry_year
card.network
card.name
```

The `TestCard` class does not encompass the complete list of whitelisted cards, though more cards will continue to be added to it. For a complete list & more information on Vantiv's whitelisted cards, please see Vantiv's documentation.

NOTE: The card object also has a `mocked_sandbox_payment_account_id`. This is not the payment_account_id that the pre-live environment will return for the card - this varies from merchant to merchant.

## Usage in test environments

This gem comes prepackaged with a way to operate in applications' test environments without making external Web requests. Users can rest assured that this self-mocked setup responds exactly like the Vantiv pre-live (certification) environment does. It is *highly recommended* that users enable this in their tests.

To enable this, simply add the following to your spec_helper, if using RSpec, or call this at the beginning of the test suite:

```ruby
Vantiv::MockedSandbox.enable_self_mocked_requests!
```

From a user perspective, the gem will behave identically as when it is not self mocked. Users can use `TestCard`s to get the responses they would also expect to receive in the certification environment. The only difference is that in mocked mode, the gem will return stable payment_account_ids for tokenizing card information, which can be accessed on a test card as `#mocked_sandbox_payment_account_id`

The only gotcha is that only whitelisted cards included in the `TestCard` class will function in the test environment. If there is one missing that is useful to you, please open an issue (or a PR).

See 'Usage in non-production environments' above for more information.

If it is _necessary_ to, this can be disabled at any time:

```ruby
Vantiv::MockedSandbox.disable_self_mocked_requests!
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/plated/vantiv-ruby.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

