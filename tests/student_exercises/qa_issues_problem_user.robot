*** Settings ***
Documentation     QA Bug Finding Tests - Problem User Issues
...               Tests to discover UI bugs with the problem_user account.
...               This user has known UI bugs that should be detected.
Library           Browser
Resource          ../../resources/common.resource
Resource          ../../resources/login_page.resource
Resource          ../../resources/products_page.resource
Resource          ../../resources/cart_page.resource
Resource          ../../resources/checkout_page.resource

Suite Setup       Open SauceDemo
Suite Teardown    Close SauceDemo

*** Variables ***
${PROBLEM_USER}    problem_user

*** Test Cases ***
Problem User Can Login
    [Documentation]    Verify problem_user can login (baseline test)
    [Tags]    qa-issues    problem_user
    Login With Credentials    ${PROBLEM_USER}    ${VALID_PASSWORD}
    Login Should Succeed

Problem User Product Images Should Be Correct
    [Documentation]    BUG: problem_user sees wrong product images - all products show same image
    [Tags]    qa-issues    problem_user    bug    images
    Login As Problem User
    ${images}=    Get Elements    css=.inventory_item_img img
    ${first_src}=    Get Attribute    ${images}[0]    src
    ${second_src}=    Get Attribute    ${images}[1]    src
    ${third_src}=    Get Attribute    ${images}[2]    src
    # BUG: All images are the same for problem_user - they should be different
    Should Not Be Equal    ${first_src}    ${second_src}    BUG: All product images are identical!
    [Teardown]    Go To    ${BASE_URL}

Problem User Add To Cart Button Should Work
    [Documentation]    BUG: problem_user "Add to cart" buttons may not work correctly
    [Tags]    qa-issues    problem_user    bug    cart
    Login As Problem User
    Add Product To Cart    Sauce Labs Backpack
    # Verify cart badge shows 1 item
    Cart Badge Should Show    1
    [Teardown]    Go To    ${BASE_URL}

Problem User Product Details Should Show Correct Product
    [Documentation]    BUG: Clicking a product may show wrong product details
    [Tags]    qa-issues    problem_user    bug    product-details
    Login As Problem User
    Open Product Details    Sauce Labs Backpack
    # Verify the product name matches what was clicked
    Get Text    css=.inventory_details_name    ==    Sauce Labs Backpack
    [Teardown]    Go To    ${BASE_URL}

Problem User Remove Button Should Work
    [Documentation]    BUG: Remove button may not work for problem_user
    [Tags]    qa-issues    problem_user    bug    cart
    Login As Problem User
    Add Product To Cart    Sauce Labs Backpack
    Cart Badge Should Show    1
    Remove Product From Cart    Sauce Labs Backpack
    # Badge should disappear when cart is empty
    Get Element Count    css=.shopping_cart_badge    ==    0
    [Teardown]    Go To    ${BASE_URL}

Problem User Sort Products Name A To Z
    [Documentation]    BUG: Sorting may not work correctly for problem_user
    [Tags]    qa-issues    problem_user    bug    sorting
    Login As Problem User
    Sort Products By    az
    ${items}=    Get Elements    css=.inventory_item_name
    ${first_name}=    Get Text    ${items}[0]
    ${last_name}=    Get Text    ${items}[5]
    # A should come before T alphabetically
    Should Be True    "${first_name}" < "${last_name}"    BUG: Products not sorted A-Z correctly
    [Teardown]    Go To    ${BASE_URL}

Problem User Sort Products Name Z To A
    [Documentation]    BUG: Sorting Z-A may not work correctly
    [Tags]    qa-issues    problem_user    bug    sorting
    Login As Problem User
    Sort Products By    za
    ${items}=    Get Elements    css=.inventory_item_name
    ${first_name}=    Get Text    ${items}[0]
    ${last_name}=    Get Text    ${items}[5]
    # Z should come before A in reverse sort
    Should Be True    "${first_name}" > "${last_name}"    BUG: Products not sorted Z-A correctly
    [Teardown]    Go To    ${BASE_URL}

Problem User Sort Products Price Low To High
    [Documentation]    BUG: Price sorting low-to-high may not work
    [Tags]    qa-issues    problem_user    bug    sorting
    Login As Problem User
    Sort Products By    lohi
    ${prices}=    Get Elements    css=.inventory_item_price
    ${first_price}=    Get Text    ${prices}[0]
    ${last_price}=    Get Text    ${prices}[5]
    ${first_num}=    Evaluate    float("${first_price}".replace("$", ""))
    ${last_num}=    Evaluate    float("${last_price}".replace("$", ""))
    Should Be True    ${first_num} <= ${last_num}    BUG: Prices not sorted low to high
    [Teardown]    Go To    ${BASE_URL}

Problem User Sort Products Price High To Low
    [Documentation]    BUG: Price sorting high-to-low may not work
    [Tags]    qa-issues    problem_user    bug    sorting
    Login As Problem User
    Sort Products By    hilo
    ${prices}=    Get Elements    css=.inventory_item_price
    ${first_price}=    Get Text    ${prices}[0]
    ${last_price}=    Get Text    ${prices}[5]
    ${first_num}=    Evaluate    float("${first_price}".replace("$", ""))
    ${last_num}=    Evaluate    float("${last_price}".replace("$", ""))
    Should Be True    ${first_num} >= ${last_num}    BUG: Prices not sorted high to low
    [Teardown]    Go To    ${BASE_URL}

Problem User Checkout Form Should Work
    [Documentation]    BUG: Checkout form fields may not accept input
    [Tags]    qa-issues    problem_user    bug    checkout
    Login As Problem User
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    Proceed To Checkout
    Fill Text    id=first-name    Test
    Fill Text    id=last-name    User
    Fill Text    id=postal-code    12345
    # Verify the fields actually contain the values
    Get Text    id=first-name    ==    Test
    Get Text    id=last-name    ==    User
    Get Text    id=postal-code    ==    12345
    [Teardown]    Go To    ${BASE_URL}

Problem User Cart Page Should Show Correct Items
    [Documentation]    BUG: Cart page may show incorrect items
    [Tags]    qa-issues    problem_user    bug    cart
    Login As Problem User
    Add Product To Cart    Sauce Labs Backpack
    Add Product To Cart    Sauce Labs Bike Light
    Open Cart
    Cart Should Contain    Sauce Labs Backpack
    Cart Should Contain    Sauce Labs Bike Light
    [Teardown]    Go To    ${BASE_URL}

Problem User Product Link In Cart Should Work
    [Documentation]    BUG: Clicking product name in cart may go to wrong product
    [Tags]    qa-issues    problem_user    bug    cart    navigation
    Login As Problem User
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    Click    css=.cart_item .inventory_item_name
    # Should show the correct product detail page
    Get Text    css=.inventory_details_name    ==    Sauce Labs Backpack
    [Teardown]    Go To    ${BASE_URL}

*** Keywords ***
Login As Problem User
    [Documentation]    Login with problem_user credentials
    Go To    ${BASE_URL}
    Login With Credentials    ${PROBLEM_USER}    ${VALID_PASSWORD}
    Login Should Succeed
