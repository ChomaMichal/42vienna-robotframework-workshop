*** Settings ***
Documentation     QA Bug Finding Tests - Cart Functionality Issues
...               Comprehensive tests for shopping cart behavior.
Library           Browser
Library           Collections
Resource          ../../resources/common.resource
Resource          ../../resources/login_page.resource
Resource          ../../resources/products_page.resource
Resource          ../../resources/cart_page.resource

Suite Setup       Open SauceDemo
Suite Teardown    Close SauceDemo

*** Test Cases ***
Cart Initially Empty
    [Documentation]    Verify cart is empty on fresh login
    [Tags]    qa-issues    cart    initial-state
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Get Element Count    css=.shopping_cart_badge    ==    0
    [Teardown]    Go To    ${BASE_URL}

Cart Badge Shows Correct Count
    [Documentation]    BUG: Cart badge should show correct item count
    [Tags]    qa-issues    cart    badge
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Cart Badge Should Show    1
    Add Product To Cart    Sauce Labs Bike Light
    Cart Badge Should Show    2
    Add Product To Cart    Sauce Labs Bolt T-Shirt
    Cart Badge Should Show    3
    [Teardown]    Go To    ${BASE_URL}

Cart Page Shows Added Items
    [Documentation]    BUG: Cart page should show all added items
    [Tags]    qa-issues    cart    display
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Add Product To Cart    Sauce Labs Bike Light
    Open Cart
    Cart Should Contain    Sauce Labs Backpack
    Cart Should Contain    Sauce Labs Bike Light
    [Teardown]    Go To    ${BASE_URL}

Cart Item Shows Quantity
    [Documentation]    Verify each item shows quantity of 1
    [Tags]    qa-issues    cart    display
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    ${qty}=    Get Text    css=.cart_quantity
    Should Be Equal    ${qty}    1
    [Teardown]    Go To    ${BASE_URL}

Cart Item Shows Price
    [Documentation]    BUG: Cart items should show prices
    [Tags]    qa-issues    cart    display    prices
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    ${price}=    Get Text    css=.cart_item .inventory_item_price
    Should Match Regexp    ${price}    \\$\\d+\\.\\d{2}
    [Teardown]    Go To    ${BASE_URL}

Cart Item Shows Description
    [Documentation]    BUG: Cart items should show descriptions
    [Tags]    qa-issues    cart    display
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    ${desc}=    Get Text    css=.cart_item .inventory_item_desc
    Should Not Be Empty    ${desc}
    [Teardown]    Go To    ${BASE_URL}

Remove Item From Cart Page
    [Documentation]    Verify remove button works in cart page
    [Tags]    qa-issues    cart    remove
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Add Product To Cart    Sauce Labs Bike Light
    Open Cart
    Click    css=.cart_item:has-text("Sauce Labs Backpack") button
    # Should only have 1 item left
    ${items}=    Get Elements    css=.cart_item
    ${count}=    Get Length    ${items}
    Should Be Equal As Numbers    ${count}    1
    Cart Badge Should Show    1
    [Teardown]    Go To    ${BASE_URL}

Remove All Items From Cart
    [Documentation]    BUG: Removing all items should clear cart completely
    [Tags]    qa-issues    cart    remove
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Add Product To Cart    Sauce Labs Bike Light
    Open Cart
    Click    css=.cart_item:has-text("Sauce Labs Backpack") button
    Click    css=.cart_item:has-text("Sauce Labs Bike Light") button
    Cart Should Be Empty
    Get Element Count    css=.shopping_cart_badge    ==    0
    [Teardown]    Go To    ${BASE_URL}

Cart Item Link Goes To Product Detail
    [Documentation]    BUG: Clicking item name in cart should go to product detail
    [Tags]    qa-issues    cart    navigation
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    Click    css=.cart_item .inventory_item_name
    Get Url    *=    inventory-item.html
    Get Text    css=.inventory_details_name    ==    Sauce Labs Backpack
    [Teardown]    Go To    ${BASE_URL}

Cart Preserves Items After Navigation
    [Documentation]    BUG: Cart should preserve items when navigating
    [Tags]    qa-issues    cart    persistence
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Cart Badge Should Show    1
    # Navigate to product detail
    Open Product Details    Sauce Labs Bike Light
    # Cart should still have 1 item
    Cart Badge Should Show    1
    # Go back
    Click    id=back-to-products
    Cart Badge Should Show    1
    [Teardown]    Go To    ${BASE_URL}

Cart After Continue Shopping
    [Documentation]    BUG: Cart items should persist after continue shopping
    [Tags]    qa-issues    cart    persistence
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Add Product To Cart    Sauce Labs Bike Light
    Open Cart
    Continue Shopping
    Cart Badge Should Show    2
    [Teardown]    Go To    ${BASE_URL}

Add Product From Detail Page Updates Cart
    [Documentation]    BUG: Adding from detail page should update cart badge
    [Tags]    qa-issues    cart    product-details
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Open Product Details    Sauce Labs Backpack
    Click    css=button[id^="add-to-cart"]
    Cart Badge Should Show    1
    [Teardown]    Go To    ${BASE_URL}

Remove Product From Detail Page Updates Cart
    [Documentation]    BUG: Removing from detail page should update cart badge
    [Tags]    qa-issues    cart    product-details
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Open Product Details    Sauce Labs Backpack
    # Button should say Remove
    ${button}=    Get Text    css=button[id^="remove"]
    Should Be Equal    ${button}    Remove
    Click    css=button[id^="remove"]
    Get Element Count    css=.shopping_cart_badge    ==    0
    [Teardown]    Go To    ${BASE_URL}

Button Changes To Remove After Add
    [Documentation]    Verify button text changes from "Add to cart" to "Remove"
    [Tags]    qa-issues    cart    buttons
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    ${btn_before}=    Get Text    css=.inventory_item:has-text("Sauce Labs Backpack") button
    Should Be Equal    ${btn_before}    Add to cart
    Add Product To Cart    Sauce Labs Backpack
    ${btn_after}=    Get Text    css=.inventory_item:has-text("Sauce Labs Backpack") button
    Should Be Equal    ${btn_after}    Remove
    [Teardown]    Go To    ${BASE_URL}

Button Changes Back To Add After Remove
    [Documentation]    Verify button text changes back to "Add to cart" after remove
    [Tags]    qa-issues    cart    buttons
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Remove Product From Cart    Sauce Labs Backpack
    ${btn}=    Get Text    css=.inventory_item:has-text("Sauce Labs Backpack") button
    Should Be Equal    ${btn}    Add to cart
    [Teardown]    Go To    ${BASE_URL}

Cart Empty State Message
    [Documentation]    BUG: Empty cart may not show helpful message
    [Tags]    qa-issues    cart    ux
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Open Cart
    Cart Should Be Empty
    # Cart page should still be navigable
    Get Element Count    id=checkout    ==    1
    Get Element Count    id=continue-shopping    ==    1
    [Teardown]    Go To    ${BASE_URL}

Cart With Maximum Items
    [Documentation]    Test cart behavior with all available products
    [Tags]    qa-issues    cart    boundary
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Add Product To Cart    Sauce Labs Backpack
    Add Product To Cart    Sauce Labs Bike Light
    Add Product To Cart    Sauce Labs Bolt T-Shirt
    Add Product To Cart    Sauce Labs Fleece Jacket
    Add Product To Cart    Sauce Labs Onesie
    Add Product To Cart    Test.allTheThings() T-Shirt (Red)
    Cart Badge Should Show    6
    Open Cart
    ${items}=    Get Elements    css=.cart_item
    ${count}=    Get Length    ${items}
    Should Be Equal As Numbers    ${count}    6
    [Teardown]    Go To    ${BASE_URL}

*** Keywords ***
# Using imported keywords from resources
