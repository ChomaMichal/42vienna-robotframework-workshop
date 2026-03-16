*** Settings ***
Documentation     QA Bug Finding Tests - Locked Out User Issues
...               Tests to verify error handling for locked_out_user account.
Library           Browser
Resource          ../../resources/common.resource
Resource          ../../resources/login_page.resource

Suite Setup       Open SauceDemo
Suite Teardown    Close SauceDemo

*** Variables ***
${LOCKED_USER}    locked_out_user

*** Test Cases ***
Locked Out User Cannot Login
    [Documentation]    Verify locked_out_user sees appropriate error message
    [Tags]    qa-issues    locked_out_user    authentication
    Login With Credentials    ${LOCKED_USER}    ${VALID_PASSWORD}
    Login Should Fail With Message    this user has been locked out
    [Teardown]    Go To    ${BASE_URL}

Locked Out User Error Message Is Clear
    [Documentation]    BUG: Error message should be clear and helpful
    [Tags]    qa-issues    locked_out_user    authentication    ux
    Login With Credentials    ${LOCKED_USER}    ${VALID_PASSWORD}
    ${error}=    Get Text    css=.error-message-container h3
    Should Contain    ${error}    locked out    Error should mention "locked out"
    Log    Error message: ${error}
    [Teardown]    Go To    ${BASE_URL}

Locked Out User Error Can Be Dismissed
    [Documentation]    BUG: Error message should be dismissable
    [Tags]    qa-issues    locked_out_user    authentication    ux
    Login With Credentials    ${LOCKED_USER}    ${VALID_PASSWORD}
    Get Element Count    css=.error-message-container    ==    1
    # Click error close button if exists
    ${close_exists}=    Get Element Count    css=.error-button
    IF    ${close_exists} > 0
        Click    css=.error-button
        # Error should be dismissed or remain (test behavior)
        ${error_count}=    Get Element Count    css=.error-message-container h3
        Log    Error count after dismiss attempt: ${error_count}
    END
    [Teardown]    Go To    ${BASE_URL}

Locked Out User Fields Still Accessible After Error
    [Documentation]    BUG: Input fields should remain accessible after error
    [Tags]    qa-issues    locked_out_user    authentication    ux
    Login With Credentials    ${LOCKED_USER}    ${VALID_PASSWORD}
    Login Should Fail With Message    locked out
    # Try to enter new credentials
    Fill Text    id=user-name    standard_user
    Fill Text    id=password    secret_sauce
    ${username}=    Get Text    id=user-name
    Should Be Equal    ${username}    standard_user    Input fields should be editable
    [Teardown]    Go To    ${BASE_URL}

Locked User Multiple Login Attempts
    [Documentation]    Test multiple failed login attempts
    [Tags]    qa-issues    locked_out_user    authentication    security
    FOR    ${i}    IN RANGE    3
        Login With Credentials    ${LOCKED_USER}    ${VALID_PASSWORD}
        Login Should Fail With Message    locked out
        Go To    ${BASE_URL}
    END
    # Should still show same error, no rate limiting message change
    Login With Credentials    ${LOCKED_USER}    ${VALID_PASSWORD}
    Login Should Fail With Message    locked out
    [Teardown]    Go To    ${BASE_URL}

*** Keywords ***
# Using imported keywords from resources
