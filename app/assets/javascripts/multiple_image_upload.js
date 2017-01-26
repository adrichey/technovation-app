(function multipleImageUpload() {
  var screenshotUploadForm = document.getElementById('team_submission_screenshots');
  if (!screenshotUploadForm) {
    return;
  }
  var allowed = ['image/bmp', 'image/jpg', 'image/jpeg', 'image/gif', 'image/png'];
  var awsKey = screenshotUploadForm.querySelector('input[name="key"]').value;
  var fileInput = screenshotUploadForm.querySelector('input[type="file"]');
  var formKeyElements = screenshotUploadForm.querySelectorAll('[type="hidden"][value]');
  var formKeyObj = {};
  forEach(formKeyElements, function(el) {
    formKeyObj[el.name] = el.value;
  });


  // pendingUploads is an array of objects where each looks like:
  // { fileName: foo.png, status: ['fresh', 'pending', 'success', 'error']}
  var pendingUploads = [];
  screenshotUploadForm.addEventListener('submit', function(e) {
    e.preventDefault();
    var files = fileInput.files;

    forEach(files, function(file) {
      var isAllowed = allowed.indexOf(file.type) !== -1;
      if (isAllowed) {
        pendingUploads.push({
          fileName: file.name,
          status: 'fresh'
        });
        defer(function() {
          uploadFile(file);
        });
      }
    });
    handleUploadCompletion();
  });

  function uploadFile(file) {
    var formData = new FormData();
    var formKeys = Object.keys(formKeyObj);
    formKeys.forEach(function(key) {
      formData.append(key, formKeyObj[key]);
    });
    formData.append('file', file, file.name);

    var fileIndex = findIndex(pendingUploads, function(item) {
      return item.fileName === file.name;
    });

    pendingUploads[fileIndex].status = 'pending';

    $.ajax({
      url: screenshotUploadForm.action,
      data: formData,
      cache: false,
      contentType: false,
      processData: false,
      type: 'POST',
      success: function(data) {
        pendingUploads[fileIndex].status = 'success';
      },
      error: function(err) {
        // TODO: Handle errors
        console.error(err);
      }
    });
  }

  function handleUploadCompletion() {
    var isDone = pendingUploads.reduce(function(r, item) {
      // TODO: Add error handling
      return r || (item.status == 'success');
    }, false);
    if (!isDone) {
      setTimeout(handleUploadCompletion, 100);
    } else {
      var payload = [];
      pendingUploads.forEach(function(item) {
        payload.push(awsKey.replace('${filename}', item.fileName));
      });
      console.log(payload);
    }
  }

})();
