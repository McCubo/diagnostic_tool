export function downloadCSVFile(headers, data, fileName) {
    if (!headers || !data || !data.length || Array.isArray(data) === false) {
        return null;
    }

    const csvString = generateCsvString(headers, data);

    const blob = new Blob([csvString])
    const exportedFilename = fileName ? fileName+'.csv' :'export.csv'
    
    const link = document.createElement("a")
    if(link.download !== undefined){
        const url = URL.createObjectURL(blob)
        link.setAttribute("href", url)
        link.setAttribute("download", exportedFilename)
        link.style.visibility='hidden'
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
    }
}

function generateCsvString(headers, objArray) {
    const columnDelimiter = ',';
    const lineDelimiter = '\r\n';
    const enclosingCharacter = '"';
    const headerKeys = Object.keys(headers);
    const headerValues = Object.values(headers);
    
    let csvString = '';
    csvString += headerValues.join(columnDelimiter);
    csvString += lineDelimiter;

    objArray.forEach(dataEntry => {
        let row = '';
        headerKeys.forEach(key => {
            if (row !== '') {
                row += columnDelimiter;
            }
            row += `${enclosingCharacter}${dataEntry[key]}${enclosingCharacter}`;
        });
        csvString += row + lineDelimiter;
    })

    return csvString;
}