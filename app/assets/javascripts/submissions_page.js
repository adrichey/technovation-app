(function submissionsPage() {
  if (!document.querySelector('[data-team-submissions]')) {
    return;
  }

  var wrapper = document.getElementById("ts-app-description-wrapper");
  var buttonsWrapper = document.getElementById("ts-app-description-buttons-wrapper");
  var primaryEditableButton = document.getElementById("ts-primary-editable-btn");
  var cancelEditableButton = document.getElementById("ts-cancel-editable-btn");
  var editableContent = wrapper.querySelectorAll('[data-editable]');

  var editableWrapperClass = 'ts-app-description--editable';
  var visibleCancelButtonClass = 'ts-app-description__cancel-btn--show';

  // actual object
  var contentObj = Array.prototype.reduce.call(editableContent, function(obj, node) {
    obj[node.dataset.name] = node.innerText;
    return obj;
  }, {});

  var tempObject = {};
  cloneContentObjToTempObj();

  primaryEditableButton.addEventListener('click', makeContentEditable);

  function makeContentEditable() {
    primaryEditableButton.removeEventListener('click', makeContentEditable);
    primaryEditableButton.innerText = 'Save Changes';

    wrapper.classList.add(editableWrapperClass);
    cancelEditableButton.classList.add(visibleCancelButtonClass);

    Array.prototype.forEach.call(editableContent, function(node) {
      node.contentEditable = true;
      node.addEventListener('input', editTempObject);
    });

    primaryEditableButton.addEventListener('click', saveChanges);
    cancelEditableButton.addEventListener('click', cancelChanges);
  }

  function editTempObject(e) {
    var nodeName = e.target.dataset.name;
    tempObject[nodeName] = e.target.innerText;
  }

  function cloneContentObjToTempObj() {
    Object.keys(contentObj).forEach((key) => {
      tempObject[key] = contentObj[key];
    });
  }

  // Submit changes to API
  function saveChanges() {
    primaryEditableButton.removeEventListener('click', saveChanges);

    var path = wrapper.dataset.updateUrl;
    var payload = {
      [wrapper.dataset.objectName]: tempObject
    }

    // Todo: Show success toast if success and error if error.
    // If success, update content in contentObj to match tempObject
    $.ajax(path, {
      method: 'PUT',
      data: payload,
      error: function(res, status) {
        if (res.status === 422) {
          console.log({ res: res });
        }
      }
    }).done(function(res) {
      removeContentEditable();
    });

  }

  function cancelChanges() {
    cancelEditableButton.removeEventListener('click', cancelChanges);

    cloneContentObjToTempObj();
    Array.prototype.forEach.call(editableContent, function(node) {
      node.innerText = contentObj[node.dataset.name];
    });

    removeContentEditable();
  }

  function removeContentEditable() {
    wrapper.classList.remove(editableWrapperClass);
    cancelEditableButton.classList.remove(visibleCancelButtonClass);

    Array.prototype.forEach.call(editableContent, function(node) {
      node.contentEditable = false;
    });
    primaryEditableButton.innerText = 'Edit App Info';
    primaryEditableButton.addEventListener('click', makeContentEditable);
  }
})();
