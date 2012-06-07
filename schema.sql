/* Authentication should always be possible via password (assuming user
 * has created a local password). Other options for the future include
 * OAuth2.0 or OpenID
 */
CREATE TABLE accounts (
    account_id  INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    email       CHAR(128) NOT NULL,
    PRIMARY KEY (account_id),
    UNIQUE KEY email (email)
);

/* Not sure how to handle this - we should have some kind of username
 * for all methods probably, except that makes things more complicated
 * for anything other than user/pass auth.
 * 
 * auth_type should be something like 'local', 'google', 'openid', 'facebook'
 */
CREATE TABLE account_auths (
    account_auth_id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    account_id INT(10) UNSIGNED NOT NULL,
    auth_type CHAR(10) NOT NULL,
    PRIMARY KEY (account_auth_id),
    KEY account_id (account_id)
);

/* Local authentication requires a password */
CREATE TABLE account_auths_local (
    id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    account_auth_id INT(10) UNSIGNED NOT NULL,
    password CHAR(40),
    PRIMARY KEY (id),
    UNIQUE KEY account_auth_id(account_auth_id)
);
