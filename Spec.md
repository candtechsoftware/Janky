# Typed Language Spec



### Types For Declarations

Primtatives:
    - int
    - bigint
    - uint  // Will validate that number is greater or equal 0
    - float // Will convert numbers to float, will fail if can't convert
    - bool
    - string
    - date
    - null
    - any

Collections:
    - Array
    - Record<K, V>
    - Interface
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
// can resuse Transformations and Validators
nameValidator: Validator = { min: 3, max: 20, uuid, starts_with: "A"}
nameTransformer: Transformer = { trim }

inteface Person {
    name: string | nameTransformer | nameValidator
    age: int;
    // they can also be inlined but must main
    salary: float |_| { percision: 2 }
    is_admin: bool
    family_tree: Record<string, Person>;
    list: Array<string | { trim } | { ends_with: 's' }>;
    kind: Kind;
}
```


### Creating Custom Validation

Validation function will be a function that takes the item as an argument.
The Item of the object will always have the following property. The function
returns a bool that if true will pass will fail if false. You can optionally
a message as well


```ts
inerface Object {
    type: (I, J)
              name: string | { cond: (this) => {
                        match(this.type) {
                            I => return this.value == 'I am I'
                            J => return this.value == 'I am J'
                        }
                    }
              }

}


// they can also be saved for reuse
const saleValidatorFunction: ValidFunc = (this) => {
    if this.sale {
        return this.price < (this.msrps - (this.msrp * .20)), 'Price is to low'
    }
    return true
}

interface Product {
    type: SomeEnum
    price: float
    msrp: float
    sale: bool
}
```


