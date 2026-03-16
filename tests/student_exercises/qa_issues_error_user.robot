*** Settings ***
Documentation     QA Bug Finding Tests - Error User Issues
...               Tests to discover error handling bugs with the error_user account.
...               This user triggers various error conditions in the application.
Library           Browser
Resource          ../../resources/common.resource
Resource          ../../resources/login_page.resource
Resource          ../../resources/products_page.resource
Resource          ../../resources/cart_page.resource
Resource          ../../resources/checkout_page.resource

Suite Setup       Open SauceDemo
Suite Teardown    Close SauceDemo

*** Variables ***
${ERROR_USER}    error_user

*** Test Cases ***
Error User Can Login
    [Documentation]    Verify error_user can login successfully
    [Tags]    qa-issues    error_user
    Login With Credentials    ${ERROR_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    [Teardown]    Go To    ${BASE_URL}

Error User Add To Cart Should Work
    [Documentation]    BUG: error_user may get errors when adding to cart
    [Tags]    qa-issues    error_user    bug    cart
    Login As Error User
    Add Product To Cart    Sauce Labs Backpack
    Cart Badge Should Show    1
    [Teardown]    Go To    ${BASE_URL}

Error User Add Multiple Items To Cart
    [Documentation]    BUG: Adding multiple items may fail for error_user
    [Tags]    qa-issues    error_user    bug    cart
    Login As Error User
    Add Product To Cart    Sauce Labs Backpack
    Add Product To Cart    Sauce Labs Bike Light
    Add Product To Cart    Sauce Labs Bolt T-Shirt
    Cart Badge Should Show    3
    [Teardown]    Go To    ${BASE_URL}

Error User Remove From Cart Should Work
    [Documentation]    BUG: error_user may get errors when removing from cart
    [Tags]    qa-issues    error_user    bug    cart
    Login As Error User
    Add Product To Cart    Sauce Labs Backpack
    Cart Badge Should Show    1
    Remove Product From Cart    Sauce Labs Backpack
    Get Element Count    css=.shopping_cart_badge    ==    0
    [Teardown]    Go To    ${BASE_URL}

Error User Checkout Information Form
    [Documentation]    BUG: error_user checkout form may not submit correctly
    [Tags]    qa-issues    error_user    bug    checkout
    Login As Error User
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    Test    User    12345
    # Should proceed to checkout overview page
    Get Url    *=    checkout-step-two
    [Teardown]    Go To    ${BASE_URL}

Error User Complete Checkout Should Work
    [Documentation]    BUG: error_user may get errors when completing checkout
    [Tags]    qa-issues    error_user    bug    checkout    critical
    Login As Error User
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    Test    User    12345
    Complete Checkout
    Order Should Be Confirmed
    [Teardown]    Go To    ${BASE_URL}

Error User Sorting Should Work
    [Documentation]    BUG: Sorting may trigger errors for error_user
    [Tags]    qa-issues    error_user    bug    sorting
    Login As Error User
    Sort Products By    az
    # No error should appear
    Get Element Count    css=.error-message-container    ==    0
    Sort Products By    za
    Get Element Count    css=.error-message-container    ==    0
    Sort Products By    lohi
    Get Element Count    css=.error-message-container    ==    0
    Sort Products By    hilo
    Get Element Count    css=.error-message-container    ==    0
    [Teardown]    Go To    ${BASE_URL}

Error User Product Details Page
    [Documentation]    BUG: Product details may show errors for error_user
    [Tags]    qa-issues    error_user    bug    product-details
    Login As Error User
    Open Product Details    Sauce Labs Backpack
    # Product details should load without errors
    Get Text    css=.inventory_details_name    ==    Sauce Labs Backpack
    Get Element Count    css=.error    ==    0
    [Teardown]    Go To    ${BASE_URL}

Error User Add To Cart From Product Details
    [Documentation]    BUG: Adding to cart from product details may fail
    [Tags]    qa-issues    error_user    bug    cart    product-details
    Login As Error User
    Open Product Details    Sauce Labs Backpack
    Click    css=button[id^="add-to-cart"]
    Cart Badge Should Show    1
    [Teardown]    Go To    ${BASE_URL}

Error User Remove From Cart In Cart Page
    [Documentation]    BUG: Remove button in cart page may not work for error_user
    [Tags]    qa-issues    error_user    bug    cart
    Login As Error User
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    Click    css=button[id^="remove"]
    Cart Should Be Empty
    [Teardown]    Go To    ${BASE_URL}

Error User Checkout Without Items
    [Documentation]    Verify error handling when checking out with empty cart
    [Tags]    qa-issues    error_user    edge-case    checkout
    Login As Error User
    Go To    ${BASE_URL}/cart.html
    # Checkout button should still be clickable, but process may behave oddly
    Click    id=checkout
    # Should be on checkout step one
    Get Url    *=    checkout-step-one
    [Teardown]    Go To    ${BASE_URL}

Error User Cancel Checkout Should Work
    [Documentation]    BUG: Cancel button during checkout may not work
    [Tags]    qa-issues    error_user    bug    checkout
    Login As Error User
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    Proceed To Checkout
    Click    id=cancel
    # Should return to cart
    Get Url    *=    cart.html
    [Teardown]    Go To    ${BASE_URL}

*** Keywords ***
Login As Error User
    [Documentation]    Login with error_user credentials
    Go To    ${BASE_URL}
    Login With Credentials    ${ERROR_USER}    ${VALID_PASSWORD}
    Login Should Succeed
