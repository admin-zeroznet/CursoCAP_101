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
                            },
                        desde: Date,
                        hasta: Date
                    );
    };

    entity Skills as projection on DB.Skills {
        area, 
        resource,
        level,
        area.descr as area_descr
    };

    @readonly entity Projects as projection on DB.Projects;
}

// -----------------------------  LABELS ---------------------------------

annotate app00.Resources with {
    country    @Common.ValueListWithFixedValues
               @Common.Text : country.name @Common.TextArrangement : #TextFirst;
};

annotate app00.Skills with {
    area_descr  @readonly;
};

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
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target : 'skills/@UI.Chart',
            Label : '{i18n>CHART}',
        },
    ],
    UI.FieldGroup#OverviewData : { Data : [
        { Value : email },
        { Value : phone },
    ]},
);

annotate app00.Skills with @(
      UI.LineItem: [
        {Value: area_code },
        {Value: area_descr },
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


// ------------------------------ GRAPH ------------------------------
annotate app00.Skills with @(
    Aggregation.ApplySupported : {
        Transformations          : [
            'aggregate',
            'topcount',
            'bottomcount',
            'identity',
            'concat',
            'groupby',
            'filter',
            'expand',
            'top',
            'skip',
            'orderby',
            'search'
        ],
        Rollup                   : #None,
        PropertyRestrictions     : true,
        GroupableProperties : [
            area_code,
        ],
        AggregatableProperties : [
            {
                $Type : 'Aggregation.AggregatablePropertyType',
                Property : level,
                RecommendedAggregationMethod : 'sum',
                SupportedAggregationMethods : [
                    'min',
                    'max',
                    'sum'
                ],
            },
        ],
    }
);

annotate app00.Skills with @(
    Analytics.AggregatedProperties : [
    {
        Name                 : 'minAmount',
        AggregationMethod    : 'min',
        AggregatableProperty : 'level',
        ![@Common.Label]     : 'Minimal Level'
    },
    {
        Name                 : 'maxAmount',
        AggregationMethod    : 'max',
        AggregatableProperty : 'level',
        ![@Common.Label]     : 'Maximun Level'
    },
    {
        Name                 : 'sumAmount',
        AggregationMethod    : 'sum',
        AggregatableProperty : 'level',
        ![@Common.Label]     : 'Level'
    }
    ],
);

annotate app00.Skills with @(
    UI.Chart : {
        Title : '{i18n>LEVELCHART}',
        ChartType : #Pie,
        Measures :  [sumAmount],
        Dimensions : [area_code],
        MeasureAttributes   : [{
                $Type   : 'UI.ChartMeasureAttributeType',
                Measure : sumAmount,
                Role    : #Axis1
        }],
        DimensionAttributes : [
            {
                $Type     : 'UI.ChartDimensionAttributeType',
                Dimension : area_code,
                Role      : #Category
            },
        ],
    },
);