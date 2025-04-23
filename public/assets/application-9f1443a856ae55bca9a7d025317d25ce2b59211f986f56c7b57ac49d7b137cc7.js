function fetchLoans() {
    fetch('/loans')  // Adjust the URL to match your API endpoint
      .then(response => response.json())
      .then(data => {
        const loansTableBody = document.getElementById("loans-table-body");
        loansTableBody.innerHTML = '';  // Clear the table body before adding new rows
  
        data.forEach(loan => {
          const row = document.createElement("tr");
          row.innerHTML = `
            <td>${loan.id}</td>
            <td>${loan.amount}</td>
            <td>${loan.duration}</td>
            <td>${loan.status}</td>
          `;
          loansTableBody.appendChild(row);
        });
      })
      .catch(error => console.error('Error fetching loans:', error));
  }
  
  document.addEventListener("DOMContentLoaded", function() {
    fetchLoans();
  });
