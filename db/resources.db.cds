namespace resources.db;

using { sap.common as SAP } from '@sap/cds/common';


entity Resources {
    key id          : String(50);
        name        : String(200);
        country     : Association to SAP.Countries;
        phone       : String(50);
        email       : String(200);
        skills      : Composition of many Skills on skills.resource = $self;
}
annotate Resources with  {
    id         @title : '{i18n>ID}'; 
    name       @title : '{i18n>NAME}'
               @Core.Immutable;
    country    @title : '{i18n>COUNTRY}' 
               @Core.Immutable;
    phone      @title : '{i18n>PHONE}' @Communication.IsPhoneNumber;
    email      @title : '{i18n>EMAIL}' @Communication.IsEmailAddress @mandatory;
};

entity Areas :  SAP.CodeList {
    key code: String(5)
};
annotate Areas with {
    descr  @Core.Immutable;
};

entity Skills {
    key area    : Association to Areas;
    key resource: Association to Resources;
        level   : Integer;   
};
annotate Skills with {
    area    @title : '{i18n>AREA}';
    level   @title : '{i18n>LEVEL}';     
};

entity Projects {
    key id: String(50);
} 