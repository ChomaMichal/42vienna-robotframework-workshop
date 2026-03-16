*** Settings ***
Documentation     QA Bug Finding Tests - Product and Sorting Issues
...               Tests for product display, sorting, filtering, and related issues.
Library           Browser
Library           Collections
Resource          ../../resources/common.resource
Resource          ../../resources/login_page.resource
Resource          ../../resources/products_page.resource

Suite Setup       Open SauceDemo
Suite Teardown    Close SauceDemo

*** Test Cases ***
Products Page Displays Six Products
    [Documentation]    Verify exactly 6 products are displayed
    [Tags]    qa-issues    products    display
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Product Count Should Be    6
    [Teardown]    Go To    ${BASE_URL}

All Products Have Names
    [Documentation]    BUG: All products should have visible names
    [Tags]    qa-issues    products    display
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    ${names}=    Get Elements    css=.inventory_item_name
    ${count}=    Get Length    ${names}
    Should Be Equal As Numbers    ${count}    6
    FOR    ${name}    IN    @{names}
        ${text}=    Get Text    ${name}
        Should Not Be Empty    ${text}    Product name should not be empty
    END
    [Teardown]    Go To    ${BASE_URL}

All Products Have Descriptions
    [Documentation]    BUG: All products should have descriptions
    [Tags]    qa-issues    products    display
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    ${descriptions}=    Get Elements    css=.inventory_item_desc
    FOR    ${desc}    IN    @{descriptions}
        ${text}=    Get Text    ${desc}
        Should Not Be Empty    ${text}    Product description should not be empty
    END
    [Teardown]    Go To    ${BASE_URL}

All Products Have Prices
    [Documentation]    BUG: All products should have valid prices
    [Tags]    qa-issues    products    display    prices
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    ${prices}=    Get Elements    css=.inventory_item_price
    FOR    ${price}    IN    @{prices}
        ${text}=    Get Text    ${price}
        Should Match Regexp    ${text}    ^\\$\\d+\\.\\d{2}$    Price should be in format $XX.XX
    END
    [Teardown]    Go To    ${BASE_URL}

All Products Have Images
    [Documentation]    BUG: All products should have working images
    [Tags]    qa-issues    products    display    images
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    ${images}=    Get Elements    css=.inventory_item_img img
    FOR    ${img}    IN    @{images}
        ${src}=    Get Attribute    ${img}    src
        Should Contain    ${src}    .jpg    Image should have valid source
        Should Not Contain    ${src}    404    Image should not be broken
    END
    [Teardown]    Go To    ${BASE_URL}

All Products Have Add To Cart Button
    [Documentation]    BUG: All products should have Add to Cart button
    [Tags]    qa-issues    products    display    buttons
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    ${buttons}=    Get Elements    css=button[id^="add-to-cart"]
    ${count}=    Get Length    ${buttons}
    Should Be Equal As Numbers    ${count}    6
    [Teardown]    Go To    ${BASE_URL}

Sort Products A-Z Default
    [Documentation]    Verify default sorting is A-Z
    [Tags]    qa-issues    products    sorting
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    ${selected}=    Get Text    css=.active_option
    Should Contain    ${selected}    A to Z    Default sort should be A to Z
    [Teardown]    Go To    ${BASE_URL}

Sort Products A-Z Correctly Orders Products
    [Documentation]    BUG: A-Z sorting should order products alphabetically
    [Tags]    qa-issues    products    sorting
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Sort Products By    az
    ${names}=    Get Elements    css=.inventory_item_name
    ${all_names}=    Create List
    FOR    ${name}    IN    @{names}
        ${text}=    Get Text    ${name}
        Append To List    ${all_names}    ${text}
    END
    ${sorted_names}=    Copy List    ${all_names}
    Sort List    ${sorted_names}
    Lists Should Be Equal    ${all_names}    ${sorted_names}    Products not sorted A-Z correctly
    [Teardown]    Go To    ${BASE_URL}

Sort Products Z-A Correctly Orders Products
    [Documentation]    BUG: Z-A sorting should reverse alphabetical order
    [Tags]    qa-issues    products    sorting
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Sort Products By    za
    ${names}=    Get Elements    css=.inventory_item_name
    ${all_names}=    Create List
    FOR    ${name}    IN    @{names}
        ${text}=    Get Text    ${name}
        Append To List    ${all_names}    ${text}
    END
    ${sorted_names}=    Copy List    ${all_names}
    Sort List    ${sorted_names}
    Reverse List    ${sorted_names}
    Lists Should Be Equal    ${all_names}    ${sorted_names}    Products not sorted Z-A correctly
    [Teardown]    Go To    ${BASE_URL}

Sort Products Price Low To High
    [Documentation]    BUG: Price sorting low-to-high should order by price ascending
    [Tags]    qa-issues    products    sorting    prices
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Sort Products By    lohi
    ${prices}=    Get Elements    css=.inventory_item_price
    ${all_prices}=    Create List
    FOR    ${price}    IN    @{prices}
        ${text}=    Get Text    ${price}
        ${num}=    Evaluate    float("${text}".replace("$", ""))
        Append To List    ${all_prices}    ${num}
    END
    ${sorted_prices}=    Copy List    ${all_prices}
    Sort List    ${sorted_prices}
    Lists Should Be Equal    ${all_prices}    ${sorted_prices}    Prices not sorted low to high
    [Teardown]    Go To    ${BASE_URL}

Sort Products Price High To Low
    [Documentation]    BUG: Price sorting high-to-low should order by price descending
    [Tags]    qa-issues    products    sorting    prices
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Sort Products By    hilo
    ${prices}=    Get Elements    css=.inventory_item_price
    ${all_prices}=    Create List
    FOR    ${price}    IN    @{prices}
        ${text}=    Get Text    ${price}
        ${num}=    Evaluate    float("${text}".replace("$", ""))
        Append To List    ${all_prices}    ${num}
    END
    ${sorted_prices}=    Copy List    ${all_prices}
    Sort List    ${sorted_prices}
    Reverse List    ${sorted_prices}
    Lists Should Be Equal    ${all_prices}    ${sorted_prices}    Prices not sorted high to low
    [Teardown]    Go To    ${BASE_URL}

Product Prices Match Between List And Detail
    [Documentation]    BUG: Product price should be same in list and detail views
    [Tags]    qa-issues    products    prices    consistency
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    # Get price from list
    ${list_price}=    Get Text    css=.inventory_item:has-text("Sauce Labs Backpack") .inventory_item_price
    # Go to detail
    Open Product Details    Sauce Labs Backpack
    ${detail_price}=    Get Text    css=.inventory_details_price
    Should Be Equal    ${list_price}    ${detail_price}    Price mismatch between list and detail
    [Teardown]    Go To    ${BASE_URL}

Product Names Are Clickable Links
    [Documentation]    Verify product names are clickable
    [Tags]    qa-issues    products    navigation
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    ${names}=    Get Elements    css=.inventory_item_name
    FOR    ${name}    IN    @{names}
        ${clickable}=    Get Element States    ${name}    contains    enabled
        Should Be True    ${clickable}    Product name should be clickable
    END
    [Teardown]    Go To    ${BASE_URL}

Product Images Are Clickable
    [Documentation]    BUG: Product images should be clickable to go to detail
    [Tags]    qa-issues    products    navigation
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    ${images}=    Get Elements    css=.inventory_item_img
    ${first_img}=    Get Element    ${images}[0]
    Click    ${first_img}
    Get Url    *=    inventory-item.html
    [Teardown]    Go To    ${BASE_URL}

Product Detail Page Has All Information
    [Documentation]    Verify product detail page shows all required info
    [Tags]    qa-issues    products    product-details
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Open Product Details    Sauce Labs Backpack
    # Check all required elements
    Get Element Count    css=.inventory_details_name    ==    1
    Get Element Count    css=.inventory_details_desc    ==    1
    Get Element Count    css=.inventory_details_price    ==    1
    Get Element Count    css=.inventory_details_img    ==    1
    Get Element Count    css=button[id^="add-to-cart"]    ==    1
    Get Element Count    id=back-to-products    ==    1
    [Teardown]    Go To    ${BASE_URL}

Product Detail Add To Cart Button Works
    [Documentation]    Verify Add to Cart works from product detail page
    [Tags]    qa-issues    products    product-details    cart
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Open Product Details    Sauce Labs Backpack
    Click    css=button[id^="add-to-cart"]
    Cart Badge Should Show    1
    [Teardown]    Go To    ${BASE_URL}

Product Detail Remove Button Works
    [Documentation]    Verify Remove button works from product detail page
    [Tags]    qa-issues    products    product-details    cart
    Login With Credentials    ${VALID_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    Open Product Details    Sauce Labs Backpack
    Click    css=button[id^="add-to-cart"]
    Cart Badge Should Show    1
    Click    css=button[id^="remove"]
    Get Element Count    css=.shopping_cart_badge    ==    0
    [Teardown]    Go To    ${BASE_URL}

*** Keywords ***
# Using imported keywords from resources
