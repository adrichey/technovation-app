(function() {
  var countrySelectFields = {
    eventList: 'turbolinks:load',

    countryFieldId: 'account_country',

    stateFieldId: 'account_state_province',

    cityFieldId: 'account_city',

    init: function() {
      return $(document).on(this.eventList, this.initCountrySelect.bind(this));
    },

    initCountrySelect: function(e) {
      return CountryStateSelect({
        chosen_ui: true,
        chosen_options: {
          disable_search_threshold: 10,
        },
        country_id: this.countryFieldId,
      });
    },
  };

  countrySelectFields.init();
}());

(function() {
  var accountDobFields = {
    eventList: 'turbolinks:load',

    cssSelector: '.account_dob',

    init: function() {
      return $(document).on(this.eventList, this.enableChosen.bind(this));
    },

    enableChosen: function(e) {
      return $(this.cssSelector).chosen({
                                   disable_search_threshold: 8,
                                 });
    },
  };

  accountDobFields.init();
}());


(function() {
  var toggleFields = {
    cssSelector: '[data-toggle="true"]',

    init: function() {
      return $(document).on('change', this.selectorCss, this.enableToggleFields.bind(this));
    },

    enableToggleFields: function(e) {
      var $field = $(e.target),
          $toggleField = $($field.data("toggle-reveal")),
          selectedOptionText = $field.find("option:selected").text(),
          toggleValue = $field.data("toggle-value");

      if (toggleValue === selectedOptionText) {
        return $toggleField.show();
      } else {
        return $toggleField.hide();
      }
    },
  };

  toggleFields.init();
}());
