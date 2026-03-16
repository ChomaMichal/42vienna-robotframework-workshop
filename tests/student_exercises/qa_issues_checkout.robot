*** Settings ***
Documentation     QA Bug Finding Tests - Checkout Flow Issues
...               Comprehensive tests for the checkout process and payment flow.
Library           Browser
Resource          ../../resources/common.resource
Resource          ../../resources/login_page.resource
Resource          ../../resources/products_page.resource
Resource          ../../resources/cart_page.resource
Resource          ../../resources/checkout_page.resource

Suite Setup       Open SauceDemo
Suite Teardown    Close SauceDemo

*** Test Cases ***
Checkout Step One Requires First Name
    [Documentation]    Verify first name is required
    [Tags]    qa-issues    checkout    validation
    Login And Add Product
    Open Cart
    Proceed To Checkout
    Fill Text    id=last-name    User
    Fill Text    id=postal-code    12345
    Click    id=continue
    Login Should Fail With Message    First Name is required
    [Teardown]    Go To    ${BASE_URL}

Checkout Step One Requires Last Name
    [Documentation]    Verify last name is required
    [Tags]    qa-issues    checkout    validation
    Login And Add Product
    Open Cart
    Proceed To Checkout
    Fill Text    id=first-name    Test
    Fill Text    id=postal-code    12345
    Click    id=continue
    Login Should Fail With Message    Last Name is required
    [Teardown]    Go To    ${BASE_URL}

Checkout Step One Requires Postal Code
    [Documentation]    Verify postal code is required
    [Tags]    qa-issues    checkout    validation
    Login And Add Product
    Open Cart
    Proceed To Checkout
    Fill Text    id=first-name    Test
    Fill Text    id=last-name    User
    Click    id=continue
    Login Should Fail With Message    Postal Code is required
    [Teardown]    Go To    ${BASE_URL}

Checkout Step One All Fields Empty
    [Documentation]    Verify error when all fields are empty
    [Tags]    qa-issues    checkout    validation
    Login And Add Product
    Open Cart
    Proceed To Checkout
    Click    id=continue
    Get Element Count    css=.error-message-container    ==    1
    [Teardown]    Go To    ${BASE_URL}

Checkout Overview Shows Correct Item
    [Documentation]    BUG: Checkout overview should show the correct item
    [Tags]    qa-issues    checkout    display
    Login And Add Product
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    Test    User    12345
    # Verify item is shown
    Get Text    css=.inventory_item_name    ==    Sauce Labs Backpack
    [Teardown]    Go To    ${BASE_URL}

Checkout Overview Shows Item Price
    [Documentation]    Verify item price is displayed on overview
    [Tags]    qa-issues    checkout    display    prices
    Login And Add Product
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    Test    User    12345
    ${price}=    Get Text    css=.inventory_item_price
    Should Match Regexp    ${price}    \\$\\d+\\.\\d{2}
    [Teardown]    Go To    ${BASE_URL}

Checkout Overview Shows Item Total
    [Documentation]    Verify item total is calculated correctly
    [Tags]    qa-issues    checkout    display    prices
    Login And Add Product
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    Test    User    12345
    ${subtotal}=    Get Text    css=.summary_subtotal_label
    Should Contain    ${subtotal}    Item total:
    [Teardown]    Go To    ${BASE_URL}

Checkout Overview Shows Tax
    [Documentation]    Verify tax is calculated and displayed
    [Tags]    qa-issues    checkout    display    prices
    Login And Add Product
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    Test    User    12345
    ${tax}=    Get Text    css=.summary_tax_label
    Should Contain    ${tax}    Tax:
    Should Match Regexp    ${tax}    \\$\\d+\\.\\d{2}
    [Teardown]    Go To    ${BASE_URL}

Checkout Overview Shows Total
    [Documentation]    Verify total is calculated correctly (subtotal + tax)
    [Tags]    qa-issues    checkout    display    prices
    Login And Add Product
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    Test    User    12345
    ${total}=    Get Text    css=.summary_total_label
    Should Contain    ${total}    Total:
    [Teardown]    Go To    ${BASE_URL}

Checkout Total Calculation Is Correct
    [Documentation]    BUG: Verify total = subtotal + tax
    [Tags]    qa-issues    checkout    prices    calculation
    Login And Add Product
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    Test    User    12345
    # Get subtotal
    ${subtotal_text}=    Get Text    css=.summary_subtotal_label
    ${subtotal}=    Evaluate    float("${subtotal_text}".split("$")[1])
    # Get tax
    ${tax_text}=    Get Text    css=.summary_tax_label
    ${tax}=    Evaluate    float("${tax_text}".split("$")[1])
    # Get total
    ${total_text}=    Get Text    css=.summary_total_label
    ${total}=    Evaluate    float("${total_text}".split("$")[1])
    # Verify calculation
    ${expected_total}=    Evaluate    round(${subtotal} + ${tax}, 2)
    Should Be Equal As Numbers    ${total}    ${expected_total}    Total calculation is incorrect
    [Teardown]    Go To    ${BASE_URL}

Checkout Multiple Items Total
    [Documentation]    BUG: Verify total is correct with multiple items
    [Tags]    qa-issues    checkout    prices    calculation
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Add Product To Cart    Sauce Labs Bike Light
    Add Product To Cart    Sauce Labs Bolt T-Shirt
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    Test    User    12345
    # Verify 3 items in checkout
    ${items}=    Get Elements    css=.cart_item
    ${count}=    Get Length    ${items}
    Should Be Equal As Numbers    ${count}    3
    [Teardown]    Go To    ${BASE_URL}

Checkout Complete Shows Confirmation
    [Documentation]    Verify order completion shows confirmation
    [Tags]    qa-issues    checkout    completion
    Login And Add Product
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    Test    User    12345
    Complete Checkout
    Order Should Be Confirmed
    [Teardown]    Go To    ${BASE_URL}

Checkout Complete Shows Thank You Message
    [Documentation]    Verify thank you message is displayed
    [Tags]    qa-issues    checkout    completion
    Login And Add Product
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    Test    User    12345
    Complete Checkout
    Get Text    css=.complete-header    ==    Thank you for your order!
    [Teardown]    Go To    ${BASE_URL}

Checkout Complete Shows Order Dispatched Message
    [Documentation]    Verify dispatch message is displayed
    [Tags]    qa-issues    checkout    completion
    Login And Add Product
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    Test    User    12345
    Complete Checkout
    ${text}=    Get Text    css=.complete-text
    Should Contain    ${text}    dispatched    Order dispatch message should be shown
    [Teardown]    Go To    ${BASE_URL}

Checkout Complete Has Back Home Button
    [Documentation]    Verify Back Home button exists on completion page
    [Tags]    qa-issues    checkout    completion    navigation
    Login And Add Product
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    Test    User    12345
    Complete Checkout
    Get Element Count    id=back-to-products    ==    1
    [Teardown]    Go To    ${BASE_URL}

Checkout Complete Cart Is Cleared
    [Documentation]    BUG: Cart should be cleared after order completion
    [Tags]    qa-issues    checkout    completion    cart
    Login And Add Product
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    Test    User    12345
    Complete Checkout
    Order Should Be Confirmed
    # Cart badge should be gone
    Get Element Count    css=.shopping_cart_badge    ==    0
    [Teardown]    Go To    ${BASE_URL}

Checkout Shipping Information Displayed
    [Documentation]    Verify shipping information is shown on overview
    [Tags]    qa-issues    checkout    display
    Login And Add Product
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    Test    User    12345
    Get Element Count    css=.summary_info    ==    1
    ${info}=    Get Text    css=.summary_info
    Should Contain    ${info}    FREE PONY EXPRESS DELIVERY
    [Teardown]    Go To    ${BASE_URL}

Checkout Payment Information Displayed
    [Documentation]    Verify payment information is shown on overview
    [Tags]    qa-issues    checkout    display
    Login And Add Product
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    Test    User    12345
    ${info}=    Get Text    css=.summary_info
    Should Contain    ${info}    SauceCard    Payment info should mention SauceCard
    [Teardown]    Go To    ${BASE_URL}

*** Keywords ***
Login And Add Product
    [Documentation]    Helper to login and add a product to cart
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
