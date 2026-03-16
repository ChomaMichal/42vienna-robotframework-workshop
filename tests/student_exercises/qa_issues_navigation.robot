*** Settings ***
Documentation     QA Bug Finding Tests - Menu and Navigation Issues
...               Tests for hamburger menu, navigation, and site-wide issues.
Library           Browser
Resource          ../../resources/common.resource
Resource          ../../resources/login_page.resource
Resource          ../../resources/products_page.resource
Resource          ../../resources/cart_page.resource
Resource          ../../resources/checkout_page.resource

Suite Setup       Open SauceDemo
Suite Teardown    Close SauceDemo

*** Test Cases ***
Hamburger Menu Opens
    [Documentation]    Verify hamburger menu can be opened
    [Tags]    qa-issues    menu    navigation
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Click    id=react-burger-menu-btn
    Wait For Elements State    css=.bm-menu-wrap    visible
    Get Element Count    css=.bm-item-list a    >=    4
    [Teardown]    Go To    ${BASE_URL}

Hamburger Menu Close Button
    [Documentation]    BUG: Menu close button should work
    [Tags]    qa-issues    menu    navigation
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Click    id=react-burger-menu-btn
    Wait For Elements State    css=.bm-menu-wrap    visible
    Click    id=react-burger-cross-btn
    Wait For Elements State    css=.bm-menu-wrap    hidden    timeout=3s
    [Teardown]    Go To    ${BASE_URL}

Menu All Items Link
    [Documentation]    BUG: "All Items" link should navigate to inventory
    [Tags]    qa-issues    menu    navigation
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    # First go to cart to test navigation back
    Open Cart
    Get Url    *=    cart.html
    # Open menu and click All Items
    Click    id=react-burger-menu-btn
    Wait For Elements State    css=.bm-menu-wrap    visible
    Click    id=inventory_sidebar_link
    Get Url    *=    inventory.html
    [Teardown]    Go To    ${BASE_URL}

Menu About Link
    [Documentation]    BUG: "About" link should navigate to SauceLabs website
    [Tags]    qa-issues    menu    navigation    external
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Click    id=react-burger-menu-btn
    Wait For Elements State    css=.bm-menu-wrap    visible
    ${href}=    Get Attribute    id=about_sidebar_link    href
    Should Contain    ${href}    saucelabs.com    About link should go to saucelabs.com
    [Teardown]    Go To    ${BASE_URL}

Menu Logout
    [Documentation]    Verify logout functionality
    [Tags]    qa-issues    menu    logout    authentication
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Click    id=react-burger-menu-btn
    Wait For Elements State    css=.bm-menu-wrap    visible
    Click    id=logout_sidebar_link
    # Should be back at login page
    Get Url    ==    ${BASE_URL}/
    Get Element Count    id=login-button    ==    1
    [Teardown]    Go To    ${BASE_URL}

Menu Reset App State
    [Documentation]    BUG: Reset App State should clear cart and state
    [Tags]    qa-issues    menu    state-management
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    # Add items to cart
    Add Product To Cart    Sauce Labs Backpack
    Add Product To Cart    Sauce Labs Bike Light
    Cart Badge Should Show    2
    # Reset app state
    Click    id=react-burger-menu-btn
    Wait For Elements State    css=.bm-menu-wrap    visible
    Click    id=reset_sidebar_link
    # Close menu
    Click    id=react-burger-cross-btn
    Sleep    500ms
    # Cart should be empty
    Get Element Count    css=.shopping_cart_badge    ==    0
    # Buttons should say "Add to cart" again
    ${button}=    Get Text    css=.inventory_item:has-text("Sauce Labs Backpack") button
    Should Be Equal    ${button}    Add to cart    Buttons should reset after Reset App State
    [Teardown]    Go To    ${BASE_URL}

Footer Social Links Twitter
    [Documentation]    Verify Twitter link in footer
    [Tags]    qa-issues    footer    social    external
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    ${href}=    Get Attribute    css=.social_twitter a    href
    Should Contain    ${href}    twitter.com    Twitter link should point to twitter.com
    [Teardown]    Go To    ${BASE_URL}

Footer Social Links Facebook
    [Documentation]    Verify Facebook link in footer
    [Tags]    qa-issues    footer    social    external
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    ${href}=    Get Attribute    css=.social_facebook a    href
    Should Contain    ${href}    facebook.com    Facebook link should point to facebook.com
    [Teardown]    Go To    ${BASE_URL}

Footer Social Links LinkedIn
    [Documentation]    Verify LinkedIn link in footer
    [Tags]    qa-issues    footer    social    external
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    ${href}=    Get Attribute    css=.social_linkedin a    href
    Should Contain    ${href}    linkedin.com    LinkedIn link should point to linkedin.com
    [Teardown]    Go To    ${BASE_URL}

Product Detail Back Button
    [Documentation]    BUG: Back to products button should work correctly
    [Tags]    qa-issues    navigation    product-details
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Open Product Details    Sauce Labs Backpack
    Get Url    *=    inventory-item.html
    Click    id=back-to-products
    Get Url    *=    inventory.html
    [Teardown]    Go To    ${BASE_URL}

Cart Link Navigation
    [Documentation]    Verify cart icon navigates to cart page
    [Tags]    qa-issues    navigation    cart
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Click    css=.shopping_cart_link
    Get Url    *=    cart.html
    [Teardown]    Go To    ${BASE_URL}

Continue Shopping From Cart
    [Documentation]    Verify Continue Shopping button works
    [Tags]    qa-issues    navigation    cart
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Open Cart
    Continue Shopping
    Get Url    *=    inventory.html
    [Teardown]    Go To    ${BASE_URL}

Cancel Checkout Returns To Cart
    [Documentation]    Verify Cancel button on checkout step one
    [Tags]    qa-issues    navigation    checkout
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    Proceed To Checkout
    Get Url    *=    checkout-step-one
    Click    id=cancel
    Get Url    *=    cart.html
    [Teardown]    Go To    ${BASE_URL}

Cancel Checkout Overview Returns To Products
    [Documentation]    Verify Cancel button on checkout step two (overview)
    [Tags]    qa-issues    navigation    checkout
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    Test    User    12345
    Get Url    *=    checkout-step-two
    Click    id=cancel
    Get Url    *=    inventory.html
    [Teardown]    Go To    ${BASE_URL}

Back Home After Order Complete
    [Documentation]    Verify Back Home button after order completion
    [Tags]    qa-issues    navigation    checkout
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    Test    User    12345
    Complete Checkout
    Order Should Be Confirmed
    Click    id=back-to-products
    Get Url    *=    inventory.html
    [Teardown]    Go To    ${BASE_URL}

Multiple Product Details Navigation
    [Documentation]    BUG: Navigating between product details quickly
    [Tags]    qa-issues    navigation    product-details
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Open Product Details    Sauce Labs Backpack
    Get Text    css=.inventory_details_name    ==    Sauce Labs Backpack
    Click    id=back-to-products
    Open Product Details    Sauce Labs Bike Light
    Get Text    css=.inventory_details_name    ==    Sauce Labs Bike Light
    Click    id=back-to-products
    Open Product Details    Sauce Labs Bolt T-Shirt
    Get Text    css=.inventory_details_name    ==    Sauce Labs Bolt T-Shirt
    [Teardown]    Go To    ${BASE_URL}

*** Keywords ***
# Using imported keywords from resources
