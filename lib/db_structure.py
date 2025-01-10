import sqlite3

def get_db_structure_with_relations_and_indexes(db_path):
    try:
        conn = sqlite3.connect(db_path)
        print("Database connected successfully")
        cursor = conn.cursor()
        
        # الحصول على أسماء الجداول
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
        tables = cursor.fetchall()
        print(f"Found {len(tables)} tables")

        db_structure = {}
        for table in tables:
            table_name = table[0]
            print(f"Processing table: {table_name}")
            
            # الحصول على أعمدة الجدول
            cursor.execute(f"PRAGMA table_info({table_name});")
            columns = cursor.fetchall()
            
            # الحصول على المفاتيح الخارجية
            cursor.execute(f"PRAGMA foreign_key_list({table_name});")
            foreign_keys = cursor.fetchall()
            
            # الحصول على الفهارس
            cursor.execute(f"PRAGMA index_list({table_name});")
            indexes = cursor.fetchall()
            indexes_details = []
            for index in indexes:
                index_name = index[1]
                cursor.execute(f"PRAGMA index_info({index_name});")
                index_info = cursor.fetchall()
                indexes_details.append({
                    'index_name': index_name,
                    'index_info': index_info
                })
            
            db_structure[table_name] = {
                'columns': columns,
                'foreign_keys': foreign_keys,
                'indexes': indexes_details
            }

        conn.close()
        print("Database connection closed")
        return db_structure
    except sqlite3.Error as e:
        print(f"Database error: {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")

def print_db_structure_with_relations_and_indexes(db_structure):
    for table_name, structure in db_structure.items():
        print(f"Table: {table_name}")
        for column in structure['columns']:
            print(f"  Column: {column[1]} - Type: {column[2]}")
        
        if structure['foreign_keys']:
            print("  Foreign Keys:")
            for fk in structure['foreign_keys']:
                print(f"    From Column: {fk[3]} - To Table: {fk[2]} - To Column: {fk[4]}")
        
        if structure['indexes']:
            print("  Indexes:")
            for index in structure['indexes']:
                print(f"    Index Name: {index['index_name']}")
                for index_info in index['index_info']:
                    print(f"      Column: {index_info[2]}")
        
        print("\n")

if __name__ == "__main__":
    db_path = 'assets/nouns.db'  # تأكد من أن المسار صحيح
    structure_with_relations_and_indexes = get_db_structure_with_relations_and_indexes(db_path)
    print_db_structure_with_relations_and_indexes(structure_with_relations_and_indexes)
