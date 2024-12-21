document.addEventListener('DOMContentLoaded', function () {
    const dateInput = document.getElementById('date');            // Single date input
    const dateType = document.getElementById('dateType');        // Date type dropdown
    const dateRangeStart = document.getElementById('startDate'); // Start date input
    const dateRangeEnd = document.getElementById('endDate');     // End date input
    const generateButton = document.getElementById('generate');  // Generate button
    const outputOption = document.getElementById('outputOption');// Output option selector
    const outputArea = document.getElementById('output');        // Output textarea
    const copyButton = document.getElementById('copyButton');    // Copy to clipboard button

    const BASE_URL = "https://raw.githubusercontent.com/Nillows/WordLists/refs/heads/main/birthday/";

    // Dictionary for converting months to lowercase abbreviations
    const MONTH_ABBREVIATIONS = {
        1: "jan",
        2: "feb",
        3: "mar",
        4: "apr",
        5: "may",
        6: "jun",
        7: "jul",
        8: "aug",
        9: "sep",
        10: "oct",
        11: "nov",
        12: "dec"
    };

    // Adjust date input for granularity
    dateType.addEventListener('change', function () {
        const selectedType = dateType.value;
        if (selectedType === 'year') {
            dateInput.type = 'text'; // Switch to text for year input
            dateInput.placeholder = 'YYYY'; // Inform users of the format
            dateInput.setAttribute('pattern', '\\d{4}'); // Enforce a 4-digit year
            dateInput.value = ''; // Clear current value
        } else if (selectedType === 'month') {
            dateInput.type = 'month'; // Switch to month picker
            dateInput.placeholder = ''; // No placeholder needed for month picker
            dateInput.removeAttribute('pattern'); // Remove pattern enforcement
            dateInput.value = ''; // Clear current value
        } else {
            dateInput.type = 'date'; // Switch to date picker
            dateInput.placeholder = ''; // No placeholder needed for date picker
            dateInput.removeAttribute('pattern'); // Remove pattern enforcement
            dateInput.value = ''; // Clear current value
        }
    });

    // Helper function to construct the URL
    function buildUrl(year, month, day, allMonth = false, allYear = false) {
        const decade = year.toString().slice(0, 3) + '0'; // Correct decade logic
        const monthStr = MONTH_ABBREVIATIONS[month]; // Use abbreviation for the month
        const dayStr = day?.toString().padStart(2, '0');

        if (allYear) {
            return `${BASE_URL}${decade}s/${year}/all.txt`;
        }
        return allMonth
            ? `${BASE_URL}${decade}s/${year}/${monthStr}/all.txt`
            : `${BASE_URL}${decade}s/${year}/${monthStr}/${dayStr}.txt`;
    }

    // Function to generate curl commands for a single date
    function handleSingleDateInput(date, type, combineOutput) {
        let year, month, day;
        if (type === 'year') {
            year = parseInt(date);
            const url = buildUrl(year, null, null, false, true);
            return combineOutput
                ? `curl -s "${url}" >> combined_output.txt`
                : `curl -s "${url}" -o ${year}_all.txt`;
        } else if (type === 'month') {
            const [y, m] = date.split('-');
            year = parseInt(y);
            month = parseInt(m);
            const url = buildUrl(year, month, null, true);
            return combineOutput
                ? `curl -s "${url}" >> combined_output.txt`
                : `curl -s "${url}" -o ${year}-${MONTH_ABBREVIATIONS[month]}_all.txt`;
        } else {
            const parsedDate = new Date(date);
            year = parsedDate.getUTCFullYear(); // Use UTC year
            month = parsedDate.getUTCMonth() + 1; // Use UTC month (0-based)
            day = parsedDate.getUTCDate(); // Use UTC day
            const url = buildUrl(year, month, day);
            return combineOutput
                ? `curl -s "${url}" >> combined_output.txt`
                : `curl -s "${url}" -o ${year}-${MONTH_ABBREVIATIONS[month]}-${day}.txt`;
        }
    }

    // Validate input and generate commands
    generateButton.addEventListener('click', function () {
        const singleDate = dateInput.value.trim();
        const startDate = dateRangeStart.value.trim();
        const endDate = dateRangeEnd.value.trim();
        const type = dateType.value;
        const combineOutput = outputOption.value === 'single';

        if (singleDate && (startDate || endDate)) {
            alert("Please use either the Single Date section or the Date Range section, not both.");
            return;
        }

        let commands;

        if (singleDate) {
            commands = handleSingleDateInput(singleDate, type, combineOutput);
        } else if (startDate && endDate) {
            commands = generateCurlCommands(startDate, endDate, combineOutput);
        } else {
            outputArea.value = "Please enter valid input in one section.";
            return;
        }

        outputArea.value = commands;
    });

    // Copy to clipboard logic
    copyButton.addEventListener('click', function () {
        const outputText = outputArea.value.trim(); // Get the content of the output area
        if (!outputText) {
            alert('No commands to copy!');
            return;
        }

        navigator.clipboard.writeText(outputText)
            .then(() => {
                // Change the button text to "Copied!"
                const originalText = copyButton.textContent;
                copyButton.textContent = "Copied!";
                // Revert to original text after 2 seconds
                setTimeout(() => {
                    copyButton.textContent = originalText;
                }, 2000);
            })
            .catch(err => {
                console.error('Failed to copy text: ', err);
                alert('Failed to copy to clipboard. Please copy manually.');
            });
    });
});
