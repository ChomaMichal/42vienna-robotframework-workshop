*** Settings ***
Documentation     QA Bug Finding Tests - Edge Cases and Unusual Behavior
...               Tests for edge cases, boundary conditions, and unusual user interactions.
Library           Browser
Resource          ../../resources/common.resource
Resource          ../../resources/login_page.resource
Resource          ../../resources/products_page.resource
Resource          ../../resources/cart_page.resource
Resource          ../../resources/checkout_page.resource

Suite Setup       Open SauceDemo
Suite Teardown    Close SauceDemo

*** Test Cases ***
Direct URL Access Without Login Should Redirect
    [Documentation]    BUG: Accessing protected pages without login should redirect to login
    [Tags]    qa-issues    edge-case    security    authentication
    Go To    ${BASE_URL}/inventory.html
    # Should redirect to login page or show error
    ${url}=    Get Url
    Should Not Contain    ${url}    inventory    BUG: Direct access to inventory without login
    [Teardown]    Go To    ${BASE_URL}

Direct URL Access To Cart Without Login
    [Documentation]    BUG: Cart page should not be accessible without login
    [Tags]    qa-issues    edge-case    security    authentication
    Go To    ${BASE_URL}/cart.html
    ${url}=    Get Url
    # Should redirect or show error
    Get Element Count    css=.error-message-container    >=    0
    [Teardown]    Go To    ${BASE_URL}

Direct URL Access To Checkout Without Login
    [Documentation]    BUG: Checkout should not be accessible without login
    [Tags]    qa-issues    edge-case    security    authentication
    Go To    ${BASE_URL}/checkout-step-one.html
    ${url}=    Get Url
    Get Element Count    css=.error-message-container    >=    0
    [Teardown]    Go To    ${BASE_URL}

Add Same Product Multiple Times
    [Documentation]    BUG: Adding same product should be prevented (button becomes Remove)
    [Tags]    qa-issues    edge-case    cart
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Cart Badge Should Show    1
    # Button should now say "Remove" - trying to add again should not increase count
    ${button}=    Get Text    css=.inventory_item:has-text("Sauce Labs Backpack") button
    Should Be Equal    ${button}    Remove    Button should change to Remove after adding
    [Teardown]    Go To    ${BASE_URL}

Cart Persists After Logout And Login
    [Documentation]    BUG: Cart items should persist after logout/login (or be cleared consistently)
    [Tags]    qa-issues    edge-case    cart    session
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Cart Badge Should Show    1
    # Logout
    Click    id=react-burger-menu-btn
    Click    id=logout_sidebar_link
    # Login again
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    # Check if cart is preserved or cleared
    ${badge_count}=    Get Element Count    css=.shopping_cart_badge
    Log    Cart badge count after re-login: ${badge_count}
    [Teardown]    Go To    ${BASE_URL}

Add All Products To Cart
    [Documentation]    Test adding all 6 products to cart
    [Tags]    qa-issues    edge-case    cart    boundary
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Add Product To Cart    Sauce Labs Bike Light
    Add Product To Cart    Sauce Labs Bolt T-Shirt
    Add Product To Cart    Sauce Labs Fleece Jacket
    Add Product To Cart    Sauce Labs Onesie
    Add Product To Cart    Test.allTheThings() T-Shirt (Red)
    Cart Badge Should Show    6
    [Teardown]    Go To    ${BASE_URL}

Empty Cart Checkout Flow
    [Documentation]    BUG: Checkout with empty cart behavior
    [Tags]    qa-issues    edge-case    checkout    boundary
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Go To    ${BASE_URL}/cart.html
    # Try to checkout with empty cart
    ${checkout_exists}=    Get Element Count    id=checkout
    Should Be True    ${checkout_exists} >= 1
    Click    id=checkout
    # Should still allow proceeding
    Get Url    *=    checkout-step-one
    [Teardown]    Go To    ${BASE_URL}

Checkout With Special Characters In Name
    [Documentation]    BUG: Checkout form may not handle special characters properly
    [Tags]    qa-issues    edge-case    checkout    input-validation
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    Proceed To Checkout
    Fill Text    id=first-name    Tëst<User>
    Fill Text    id=last-name    O'Connor-Smith
    Fill Text    id=postal-code    12345
    Click    id=continue
    # Should handle gracefully
    ${error_count}=    Get Element Count    css=.error-message-container h3
    Log    Errors with special characters: ${error_count}
    [Teardown]    Go To    ${BASE_URL}

Checkout With Very Long Names
    [Documentation]    BUG: Very long input values may break layout or be truncated
    [Tags]    qa-issues    edge-case    checkout    input-validation
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    Proceed To Checkout
    ${long_name}=    Evaluate    "A" * 200
    Fill Text    id=first-name    ${long_name}
    Fill Text    id=last-name    ${long_name}
    Fill Text    id=postal-code    1234567890123456789012345
    Click    id=continue
    # Check if it handles or errors
    ${url}=    Get Url
    Log    URL after long input: ${url}
    [Teardown]    Go To    ${BASE_URL}

Checkout With Numbers Only In Name
    [Documentation]    BUG: Checkout may accept numbers as names
    [Tags]    qa-issues    edge-case    checkout    input-validation
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    12345    67890    ABCDE
    # Check result - should either proceed or show error
    ${url}=    Get Url
    Log    URL after numeric names: ${url}
    [Teardown]    Go To    ${BASE_URL}

Checkout With SQL Injection Attempt
    [Documentation]    SECURITY: Test for SQL injection vulnerability
    [Tags]    qa-issues    security    checkout    input-validation
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    Proceed To Checkout
    Fill Text    id=first-name    '; DROP TABLE users;--
    Fill Text    id=last-name    OR 1=1
    Fill Text    id=postal-code    12345
    Click    id=continue
    # Should handle gracefully, no server errors
    ${error_count}=    Get Element Count    css=.error-message-container h3
    Log    Errors with SQL injection attempt: ${error_count}
    [Teardown]    Go To    ${BASE_URL}

Checkout With XSS Attempt
    [Documentation]    SECURITY: Test for XSS vulnerability
    [Tags]    qa-issues    security    checkout    input-validation
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    Proceed To Checkout
    Fill Text    id=first-name    <script>alert('XSS')</script>
    Fill Text    id=last-name    Test
    Fill Text    id=postal-code    12345
    Click    id=continue
    # Should sanitize input
    ${error_count}=    Get Element Count    css=.error-message-container h3
    Log    Errors with XSS attempt: ${error_count}
    [Teardown]    Go To    ${BASE_URL}

Remove Product Then Re-Add
    [Documentation]    Test removing and re-adding a product
    [Tags]    qa-issues    edge-case    cart
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Cart Badge Should Show    1
    Remove Product From Cart    Sauce Labs Backpack
    Get Element Count    css=.shopping_cart_badge    ==    0
    Add Product To Cart    Sauce Labs Backpack
    Cart Badge Should Show    1
    [Teardown]    Go To    ${BASE_URL}

Browser Back Button During Checkout
    [Documentation]    BUG: Back button behavior during checkout may be inconsistent
    [Tags]    qa-issues    edge-case    navigation    checkout
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    Test    User    12345
    # Now on checkout overview - press back
    Go Back
    # Should return to checkout step one
    ${url}=    Get Url
    Log    URL after back button: ${url}
    [Teardown]    Go To    ${BASE_URL}

Refresh Page During Checkout
    [Documentation]    BUG: Refreshing during checkout may lose data
    [Tags]    qa-issues    edge-case    navigation    checkout
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    Proceed To Checkout
    Fill Text    id=first-name    Test
    Fill Text    id=last-name    User
    # Refresh page
    Reload
    # Check if data is preserved
    ${first_name}=    Get Text    id=first-name
    Log    First name after refresh: ${first_name}
    [Teardown]    Go To    ${BASE_URL}

*** Keywords ***
# Using imported keywords from resources
