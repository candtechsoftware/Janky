# Typed Language Spec



### Types For Declarations

Primtatives:
    - Int
    - Bigint
    - Uint  // Will validate that number is greater or equal 0
    - Float // Will convert numbers to float, will fail if can't convert
    - Bool
    - String
    - Date
    - Null
    - Any

Collections:
    - Array
    - Record<K, V>
    - Interface
    - Enum
    - Union


```ts

enum Kind {
    Some;
    None;
}

inteface Person {
    name: string;
    age: int;
    salary: float;
    is_admin: bool;
    family_tree: Record<string, Person>;
    list: Array<string>;
    kind: Kind;

}
```

### Validiation

Built in validation goes besides the type

Numeric Validators
    min(int): int, uint, float
    max(int): int, uint, float
    clamp(low: int, hi: int): int, uint, float
    percision: float

String Validators
    min(len:int)
    max(len:int)
    len(len:int)
    date(iso_fmt?:string)
    uuid(string)
    regex(regex:string)
    starts_with(start:string)
    ends_with(end:string)

Transformations:
    trim(string)
    trim_left(string)
    trim_right(string)
    toLowerCase(string)
    toUpperCase(string)

Validators are added after property declarations seperated by `;`

```ts
inteface Person {
    name: String(regex('^[^\W_]+$')).trim()
    age: Int(max(100))
    // they can also be inlined but must main
    salary: Float(percision(2))
    is_admin: bool
    family_tree: Record<string, Person>;
    list: Array<String>;
    kind: Kind;
}
```
