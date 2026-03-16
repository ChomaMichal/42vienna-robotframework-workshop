*** Settings ***
Documentation     QA Bug Finding Tests - Performance Glitch User Issues
...               Tests to discover performance/timing bugs with the performance_glitch_user.
...               This user experiences slow responses throughout the application.
Library           Browser
Library           DateTime
Resource          ../../resources/common.resource
Resource          ../../resources/login_page.resource
Resource          ../../resources/products_page.resource
Resource          ../../resources/cart_page.resource
Resource          ../../resources/checkout_page.resource

Suite Setup       Open SauceDemo
Suite Teardown    Close SauceDemo

*** Variables ***
${PERFORMANCE_USER}    performance_glitch_user
${MAX_LOGIN_TIME}      5
${MAX_PAGE_LOAD}       5
${MAX_ACTION_TIME}     3

*** Test Cases ***
Performance User Login Time
    [Documentation]    BUG: Login takes too long for performance_glitch_user
    [Tags]    qa-issues    performance_user    performance    login
    Go To    ${BASE_URL}
    ${start}=    Get Current Date    result_format=epoch
    Login With Credentials    ${PERFORMANCE_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    ${end}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${end} - ${start}
    Should Be True    ${duration} < ${MAX_LOGIN_TIME}    BUG: Login took ${duration}s (max ${MAX_LOGIN_TIME}s)
    [Teardown]    Go To    ${BASE_URL}

Performance User Products Page Load Time
    [Documentation]    BUG: Products page loads slowly for performance_glitch_user
    [Tags]    qa-issues    performance_user    performance    products
    Login As Performance User
    ${start}=    Get Current Date    result_format=epoch
    Go To    ${BASE_URL}/inventory.html
    Get Element    css=.inventory_list
    ${end}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${end} - ${start}
    Should Be True    ${duration} < ${MAX_PAGE_LOAD}    BUG: Page load took ${duration}s (max ${MAX_PAGE_LOAD}s)
    [Teardown]    Go To    ${BASE_URL}

Performance User Add To Cart Response Time
    [Documentation]    BUG: Adding to cart is slow for performance_glitch_user
    [Tags]    qa-issues    performance_user    performance    cart
    Login As Performance User
    ${start}=    Get Current Date    result_format=epoch
    Add Product To Cart    Sauce Labs Backpack
    Cart Badge Should Show    1
    ${end}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${end} - ${start}
    Should Be True    ${duration} < ${MAX_ACTION_TIME}    BUG: Add to cart took ${duration}s (max ${MAX_ACTION_TIME}s)
    [Teardown]    Go To    ${BASE_URL}

Performance User Can Complete Full Checkout
    [Documentation]    Verify performance_user can complete checkout despite slowness
    [Tags]    qa-issues    performance_user    performance    checkout
    Login As Performance User
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    Cart Should Contain    Sauce Labs Backpack
    Proceed To Checkout
    Fill Checkout Information    Performance    Test    12345
    Complete Checkout
    Order Should Be Confirmed
    [Teardown]    Go To    ${BASE_URL}

Performance User Sort Products
    [Documentation]    BUG: Sorting may be slow for performance_glitch_user
    [Tags]    qa-issues    performance_user    performance    sorting
    Login As Performance User
    ${start}=    Get Current Date    result_format=epoch
    Sort Products By    za
    ${items}=    Get Elements    css=.inventory_item_name
    ${first}=    Get Text    ${items}[0]
    ${end}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${end} - ${start}
    Should Be True    ${duration} < ${MAX_ACTION_TIME}    BUG: Sorting took ${duration}s (max ${MAX_ACTION_TIME}s)
    [Teardown]    Go To    ${BASE_URL}

Performance User Product Details Load Time
    [Documentation]    BUG: Product details page loads slowly
    [Tags]    qa-issues    performance_user    performance    product-details
    Login As Performance User
    ${start}=    Get Current Date    result_format=epoch
    Open Product Details    Sauce Labs Backpack
    Get Element    css=.inventory_details
    ${end}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${end} - ${start}
    Should Be True    ${duration} < ${MAX_PAGE_LOAD}    BUG: Product details took ${duration}s (max ${MAX_PAGE_LOAD}s)
    [Teardown]    Go To    ${BASE_URL}

Performance User Cart Page Load Time
    [Documentation]    BUG: Cart page loads slowly
    [Tags]    qa-issues    performance_user    performance    cart
    Login As Performance User
    Add Product To Cart    Sauce Labs Backpack
    ${start}=    Get Current Date    result_format=epoch
    Open Cart
    Get Element    css=.cart_list
    ${end}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${end} - ${start}
    Should Be True    ${duration} < ${MAX_PAGE_LOAD}    BUG: Cart page took ${duration}s (max ${MAX_PAGE_LOAD}s)
    [Teardown]    Go To    ${BASE_URL}

Performance User Navigation Back To Products
    [Documentation]    BUG: Continue Shopping button may be slow
    [Tags]    qa-issues    performance_user    performance    navigation
    Login As Performance User
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    ${start}=    Get Current Date    result_format=epoch
    Continue Shopping
    Get Element    css=.inventory_list
    ${end}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${end} - ${start}
    Should Be True    ${duration} < ${MAX_PAGE_LOAD}    BUG: Navigation took ${duration}s (max ${MAX_PAGE_LOAD}s)
    [Teardown]    Go To    ${BASE_URL}

*** Keywords ***
Login As Performance User
    [Documentation]    Login with performance_glitch_user credentials
    Go To    ${BASE_URL}
    Login With Credentials    ${PERFORMANCE_USER}    ${VALID_PASSWORD}
    Login Should Succeed
