export interface AuthOptions {
    name: string; //
    title: string; //
    magicLink?: boolean, //
    passkey?: boolean, //
    oauth: {
        github: boolean, //
        google: boolean, //
        generic?: {
            providerId: string 
            clientId: string, 
            clientSecret: string, 
            discoveryUrl: string,
        }[]
    },
    admin: boolean,
    orgs: boolean,
    sso: boolean,
    oidc: boolean,
    twoFactorAuth: boolean,
    tableNames?: {
        users: string;
        accounts: string;

    }
    
}

export interface DatabaseOptions {

}