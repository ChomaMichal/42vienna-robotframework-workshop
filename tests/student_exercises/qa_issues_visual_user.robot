*** Settings ***
Documentation     QA Bug Finding Tests - Visual User Issues
...               Tests to discover visual/UI bugs with the visual_user account.
...               This user has visual differences and rendering issues.
Library           Browser
Resource          ../../resources/common.resource
Resource          ../../resources/login_page.resource
Resource          ../../resources/products_page.resource
Resource          ../../resources/cart_page.resource
Resource          ../../resources/checkout_page.resource

Suite Setup       Open SauceDemo
Suite Teardown    Close SauceDemo

*** Variables ***
${VISUAL_USER}    visual_user

*** Test Cases ***
Visual User Can Login
    [Documentation]    Verify visual_user can login successfully
    [Tags]    qa-issues    visual_user
    Login With Credentials    ${VISUAL_USER}    ${VALID_PASSWORD}
    Login Should Succeed
    [Teardown]    Go To    ${BASE_URL}

Visual User Product Images Should Be Correct
    [Documentation]    BUG: visual_user may see incorrect/broken product images
    [Tags]    qa-issues    visual_user    bug    images    visual
    Login As Visual User
    ${images}=    Get Elements    css=.inventory_item_img img
    # Check that all images have valid src attributes
    FOR    ${img}    IN    @{images}
        ${src}=    Get Attribute    ${img}    src
        Should Contain    ${src}    .jpg    Image source should be a valid jpg
        Should Not Contain    ${src}    sl-404    BUG: Broken image detected
    END
    [Teardown]    Go To    ${BASE_URL}

Visual User Cart Icon Badge Position
    [Documentation]    BUG: Cart badge may be mispositioned for visual_user
    [Tags]    qa-issues    visual_user    bug    visual    cart
    Login As Visual User
    Add Product To Cart    Sauce Labs Backpack
    # Badge should be visible
    Get Element Count    css=.shopping_cart_badge    ==    1
    # Check badge is visible (not hidden or off-screen)
    ${badge}=    Get Element    css=.shopping_cart_badge
    ${visible}=    Get Element States    ${badge}    contains    visible
    Should Be True    ${visible}    BUG: Cart badge is not visible
    [Teardown]    Go To    ${BASE_URL}

Visual User Product Prices Should Be Aligned
    [Documentation]    BUG: Prices may be misaligned or incorrectly formatted
    [Tags]    qa-issues    visual_user    bug    visual    prices
    Login As Visual User
    ${prices}=    Get Elements    css=.inventory_item_price
    FOR    ${price}    IN    @{prices}
        ${text}=    Get Text    ${price}
        Should Match Regexp    ${text}    \\$\\d+\\.\\d{2}    BUG: Price format is incorrect
    END
    [Teardown]    Go To    ${BASE_URL}

Visual User Add To Cart Button Text
    [Documentation]    BUG: Button text may be incorrect or truncated
    [Tags]    qa-issues    visual_user    bug    visual    buttons
    Login As Visual User
    ${buttons}=    Get Elements    css=button[id^="add-to-cart"]
    FOR    ${btn}    IN    @{buttons}
        ${text}=    Get Text    ${btn}
        Should Be Equal    ${text}    Add to cart    BUG: Button text is incorrect
    END
    [Teardown]    Go To    ${BASE_URL}

Visual User Product Names Should Be Complete
    [Documentation]    BUG: Product names may be truncated or incorrect
    [Tags]    qa-issues    visual_user    bug    visual    products
    Login As Visual User
    ${names}=    Get Elements    css=.inventory_item_name
    ${expected_products}=    Create List    
    ...    Sauce Labs Backpack
    ...    Sauce Labs Bike Light
    ...    Sauce Labs Bolt T-Shirt
    ...    Sauce Labs Fleece Jacket
    ...    Sauce Labs Onesie
    ...    Test.allTheThings() T-Shirt (Red)
    FOR    ${idx}    ${name}    IN ENUMERATE    @{names}
        ${actual}=    Get Text    ${name}
        Should Be Equal    ${actual}    ${expected_products}[${idx}]    BUG: Product name mismatch
    END
    [Teardown]    Go To    ${BASE_URL}

Visual User Menu Icon Should Be Visible
    [Documentation]    BUG: Hamburger menu icon may have visual issues
    [Tags]    qa-issues    visual_user    bug    visual    menu
    Login As Visual User
    ${menu}=    Get Element    id=react-burger-menu-btn
    ${visible}=    Get Element States    ${menu}    contains    visible
    Should Be True    ${visible}    BUG: Menu button is not visible
    [Teardown]    Go To    ${BASE_URL}

Visual User Footer Should Be Visible
    [Documentation]    BUG: Footer content may be missing or misaligned
    [Tags]    qa-issues    visual_user    bug    visual    footer
    Login As Visual User
    ${footer}=    Get Element    css=.footer
    ${visible}=    Get Element States    ${footer}    contains    visible
    Should Be True    ${visible}    BUG: Footer is not visible
    # Check social media links
    Get Element Count    css=.social_twitter    ==    1
    Get Element Count    css=.social_facebook    ==    1
    Get Element Count    css=.social_linkedin    ==    1
    [Teardown]    Go To    ${BASE_URL}

Visual User Checkout Overview Price Display
    [Documentation]    BUG: Checkout prices may be incorrectly displayed
    [Tags]    qa-issues    visual_user    bug    visual    checkout
    Login As Visual User
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    Proceed To Checkout
    Fill Checkout Information    Test    User    12345
    # Verify price summary is displayed correctly
    ${item_total}=    Get Text    css=.summary_subtotal_label
    Should Match Regexp    ${item_total}    Item total: \\$\\d+\\.\\d{2}
    ${tax}=    Get Text    css=.summary_tax_label
    Should Match Regexp    ${tax}    Tax: \\$\\d+\\.\\d{2}
    ${total}=    Get Text    css=.summary_total_label
    Should Match Regexp    ${total}    Total: \\$\\d+\\.\\d{2}
    [Teardown]    Go To    ${BASE_URL}

Visual User Product Detail Image
    [Documentation]    BUG: Product detail page image may be wrong or missing
    [Tags]    qa-issues    visual_user    bug    visual    product-details
    Login As Visual User
    Open Product Details    Sauce Labs Backpack
    ${img}=    Get Element    css=.inventory_details_img
    ${src}=    Get Attribute    ${img}    src
    Should Contain    ${src}    sauce-backpack    BUG: Product detail shows wrong image
    [Teardown]    Go To    ${BASE_URL}

Visual User Logo Should Be Displayed
    [Documentation]    BUG: Site logo may have visual issues
    [Tags]    qa-issues    visual_user    bug    visual    branding
    Login As Visual User
    ${logo}=    Get Element    css=.app_logo
    ${text}=    Get Text    ${logo}
    Should Be Equal    ${text}    Swag Labs    BUG: Logo text is incorrect
    [Teardown]    Go To    ${BASE_URL}

*** Keywords ***
Login As Visual User
    [Documentation]    Login with visual_user credentials
    Go To    ${BASE_URL}
    Login With Credentials    ${VISUAL_USER}    ${VALID_PASSWORD}
    Login Should Succeed
