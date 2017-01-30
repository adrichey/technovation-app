(function submissionEditScreenshots() {
  var mainWrapper = document.getElementById('submission-screenshots-edit');
  if (!mainWrapper) {
    return;
  }

  var baseClass = 'submission-screenshots-edit';

  var wrapper = document.getElementById('edit-screenshots-wrapper');
  var images = wrapper.getElementsByTagName('img');

  for (var i = 0; i < images.length; i++) {
    var currentImg = images[i];
    var dragHandle = document.createElement('span');
    dragHandle.classList.add('fa', 'fa-bars');
    currentImg.parentElement.insertBefore(dragHandle, currentImg);
    var label = document.createElement('span');
    label.classList.add(baseClass + '__label');
    label.innerText = currentImg.alt || "";
    currentImg.parentElement.insertBefore(label, currentImg);
  }

  var draggable = dragula([wrapper], {
    mirrorContainer: mainWrapper
  });

  draggable.on('drop', updateOrder);

  var deleteButtons = $('.' + baseClass + ' [data-method="delete"]');
  deleteButtons.on('ajax:success', function(e, xhr) {
    var deletedImgSrc = e.target.parentElement.querySelector('img').src;
    var event = new CustomEvent('imagedeleted', {bubbles: true, cancelable: true, detail: deletedImgSrc});
    mainWrapper.dispatchEvent(event);
    createFlashNotification('success', 'Image successfully deleted!');
    e.target.parentElement.remove();

    if (images.length < 1) {
      // Hacky but there's a significant amount of work that would need to happen
      // to revert the gallery back to an empty state if all images are deleted.
      // Temporarily just closing the modal and removing the edit button instead.
      mainWrapper.parentElement.querySelector('.modalify__close').click();
      document.querySelector('[data-modal-trigger="screenshots-edit"]').remove();
    }
  });

  deleteButtons.on('ajax:error', function(e, xhr) {
    createFlashNotification('error', 'Uh uh, something went wrong. Please try again.');
  });

  function updateOrder() {
    var items = wrapper.children;
    var order = Array.prototype.map.call(items, function(item) {
      return item.querySelector('img').dataset.imageId;
    });

    var path = mainWrapper.dataset.updateUrl;
    var payload = {};
    payload[mainWrapper.dataset.objectName] = {
      screenshots: order
    };

    $.ajax(path, {
      method: 'PATCH',
      data: payload,
      success: function(res, status) {
        createFlashNotification('success', 'Screenshot order updated!');
      }
    });
  }

})();
