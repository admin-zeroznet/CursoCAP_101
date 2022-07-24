namespace resources.srv;

using { resources.db as DB  } from '../db/resources.db';

service app00 {

    @odata.draft.enabled
    @Capabilities: {
        InsertRestrictions.Insertable: false,
        UpdateRestrictions.Updatable: true,
        DeleteRestrictions.Deletable: false
    }
    entity Resources as projection on DB.Resources
    actions {
        @Common.IsActionCritical : true
        action Alta(project: String(36) 
                            @title : '{i18n>PROJECT}'
                            @Common.ValueListWithFixedValues
                            @Common: {
                                ValueList : {
                                    CollectionPath : 'Projects',
                                    Label : '',
                                    Parameters : [
                                        {$Type: 'Common.ValueListParameterInOut', 
                                         LocalDataProperty: project, 
                                         ValueListProperty: 'id'},
                                    ],
                                }
                            }
                    );
    };

    @readonly entity Projects as projection on DB.Projects;
}

// -----------------------------  LABELS ---------------------------------

annotate app00.Resources with {
    country    @Common.ValueListWithFixedValues
               @Common.Text : country.name @Common.TextArrangement : #TextFirst;
};


// -----------------------------  LAYOUTS --------------------------------
annotate app00.Resources with @(

    //List

    UI.SelectionFields : [country_code],
    UI.LineItem: [
        {Value: id,             ![@UI.Importance] : #High},
        {Value: name,           ![@UI.Importance] : #High}, 
        {Value: country_code,   ![@UI.Importance] : #High},
        {Value: email,          ![@UI.Importance] : #Low},
        {Value: phone,          ![@UI.Importance] : #Low},
    ],

    //Object 

    UI.HeaderInfo : {
        TypeName       : '{i18n>RESOURCE}',
        TypeNamePlural : '{i18n>RESOURCES}',
        Title          : {
            $Type : 'UI.DataField',
            Value : name,
        },
        TypeImageUrl : 'sap-icon://employee',
    },
    UI.HeaderFacets : [
        {
            $Type   : 'UI.ReferenceFacet',
            Target  : '@UI.FieldGroup#HeaderData',
        },
    ],
    UI.FieldGroup#HeaderData : { Data : [
        { Value : id },
        { Value : country_code },
    ]},
    UI.Facets : [     
        {  
            $Type  : 'UI.ReferenceFacet',
            Target : '@UI.FieldGroup#OverviewData',
            Label  : '{i18n>DATA}'
        },
        {  
            $Type  : 'UI.ReferenceFacet',
            Target : 'skills/@UI.LineItem',
            Label  : '{i18n>SKILLS}'
        }
    ],
    UI.FieldGroup#OverviewData : { Data : [
        { Value : email },
        { Value : phone },
    ]},
);

annotate app00.Skills with @(
      UI.LineItem: [
        {Value: area_code },
        {Value: area.descr },
//      {Value: level },
        {
            $Type               : 'UI.DataFieldForAnnotation',
            Label               : '{i18n>LEVEL}',
            Target              : '@UI.DataPoint#ratingIndicator',
            ![@UI.Importance]   : #High,
        },
    ],
    UI.DataPoint #ratingIndicator : {
        Value           : level,
        TargetValue     : 5, 
        Visualization   : #Rating,
        Title           : '{i18n>LEVEL}'
    },  
);


// -----------------------------  SECURITY -----------------------------
 
annotate app00 with @(requires: ['director','gerente']);

annotate app00.Resources with @(restrict: [
    { grant: ['READ','Alta'], to: 'gerente', where: 'country_code = $user.paises' },
    { grant: ['READ','UPDATE'], to: 'director' },
  ]); 

annotate app00.Skills with @(restrict: [
    { grant: ['READ'], to: 'gerente' },
    { grant: ['READ','UPDATE'], to: 'director' },
  ]); 

annotate app00.Countries with @(restrict: [
    { grant: 'READ', to: 'gerente', where: 'code = $user.paises' },
    { grant: ['READ'], to: 'director' },
  ]); 

// ------------------------------ ACTIONS ------------------------------

annotate app00.Resources with @(

    UI.Identification : [
        {
            $Type : 'UI.DataFieldForAction',
            Action : 'resources.srv.app00.Alta',
            Label : '{i18n>ASSIGN}',
            Criticality : 3,
        },
    ],
);