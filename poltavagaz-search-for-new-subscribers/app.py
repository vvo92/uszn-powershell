from dbfread import DBF
from csv import DictReader


def dbf_parser(path):
    dbfTable = DBF(path, encoding = '1251')
    fields_name = dbfTable.field_names
    dbfTableList = []
    for record in dbfTable:
        recordList = []
        for field in fields_name:
            recordList.append(record[field])
        dbfTableList.append(recordList)
    return dbfTableList


def csv_parser(path):
    with open(path, encoding='1251', newline='') as csv_file:
        csvTable = DictReader(csv_file, delimiter=';')
        fields_name = csvTable.fieldnames
        if fields_name[-1] == '':
            fields_name = fields_name[:-1]
        csvTableList = []
        for record in csvTable:
            recordList = []
            for field in fields_name:
                recordList.append(record[field])
            csvTableList.append(recordList)
        return csvTableList
            


def main():
    newAbonArr = dbf_parser(r'.\inbox\1_pgaz.dbf')
    atPgazArr = csv_parser(r'.\inbox\ips_at-pgaz.csv')
    PgazZbutArr = csv_parser(r'.\inbox\ips_pgaz-zbut.csv')


if __name__ == '__main__':
    main()