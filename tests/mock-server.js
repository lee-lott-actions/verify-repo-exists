const express = require('express');
const app = express();
app.use(express.json());

app.get('/repos/:owner/:repo_name', (req, res) => {
  console.log('Mock intercepted: GET /repos/' + req.params.owner + '/' + req.params.repo_name);
  console.log('Headers:', JSON.stringify(req.headers));

  // Simulate repository responses based on repo_name and owner
  if (req.params.owner === 'test-owner' && req.params.repo_name === 'test-repo') {
    // Simulate successful response with is_template true/false based on query or default
    const isTemplate = req.query.is_template === 'false' ? false : true;
    return res.status(200).json({ is_template: isTemplate });
  } else {
    // Simulate non-existent repository
    return res.status(404).json({ message: 'Not Found' });
  }
});

app.listen(3000, () => {
  console.log('Mock server listening on http://127.0.0.1:3000...');
});
