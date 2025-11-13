# shadcn/ui Development Standards

## Installation and Setup

```bash
# Initialize shadcn/ui
npx shadcn@latest init

# Add components as needed
npx shadcn@latest add button card dialog form input
```

## Component Usage Patterns

### Using shadcn/ui Components

```tsx
// ✅ Good: Import from your components directory
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";

export function Dashboard() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Dashboard</CardTitle>
      </CardHeader>
      <CardContent>
        <Button variant="default">Click me</Button>
      </CardContent>
    </Card>
  );
}

// ❌ Bad: Don't import from package (shadcn/ui is copy-paste, not npm)
import { Button } from "shadcn-ui"; // Wrong!
```

### Component Variants

```tsx
// ✅ Good: Use predefined variants
<Button variant="default">Default</Button>
<Button variant="destructive">Delete</Button>
<Button variant="outline">Outline</Button>
<Button variant="ghost">Ghost</Button>
<Button variant="link">Link</Button>

// ✅ Good: Combine variants with sizes
<Button variant="outline" size="sm">Small</Button>
<Button variant="outline" size="lg">Large</Button>

// ✅ Good: Use className for additional customization
<Button variant="outline" className="mt-4 w-full">
  Full Width Button
</Button>
```

## Customization with cn() Utility

```tsx
import { cn } from "@/lib/utils";

// ✅ Good: Use cn() for conditional classes
export function CustomButton({ className, isActive, ...props }: ButtonProps & { isActive?: boolean }) {
  return (
    <Button
      className={cn(
        "transition-all duration-200",
        isActive && "ring-2 ring-primary",
        className
      )}
      {...props}
    />
  );
}

// ✅ Good: Merge component variants with custom classes
<Button
  variant="outline"
  className={cn(
    "hover:scale-105",
    isPending && "opacity-50 cursor-not-allowed"
  )}
>
  Submit
</Button>
```

## Form Components with react-hook-form + zod

```tsx
"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import * as z from "zod";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { toast } from "@/hooks/use-toast";

// ✅ Good: Define schema with zod
const formSchema = z.object({
  email: z.string().email("Invalid email address"),
  password: z.string().min(8, "Password must be at least 8 characters"),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: "Passwords don't match",
  path: ["confirmPassword"],
});

export function SignupForm() {
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      email: "",
      password: "",
      confirmPassword: "",
    },
  });
  
  async function onSubmit(values: z.infer<typeof formSchema>) {
    try {
      await signup(values);
      toast({
        title: "Success",
        description: "Your account has been created.",
      });
    } catch (error) {
      toast({
        title: "Error",
        description: "Something went wrong.",
        variant: "destructive",
      });
    }
  }
  
  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input type="email" placeholder="you@example.com" {...field} />
              </FormControl>
              <FormDescription>We'll never share your email.</FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />
        
        <FormField
          control={form.control}
          name="password"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Password</FormLabel>
              <FormControl>
                <Input type="password" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        
        <FormField
          control={form.control}
          name="confirmPassword"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Confirm Password</FormLabel>
              <FormControl>
                <Input type="password" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        
        <Button type="submit" disabled={form.formState.isSubmitting}>
          {form.formState.isSubmitting ? "Creating..." : "Sign Up"}
        </Button>
      </form>
    </Form>
  );
}
```

## Dialog Component Pattern

```tsx
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { useState } from "react";

// ✅ Good: Controlled dialog state
export function EditUserDialog({ user }: { user: User }) {
  const [open, setOpen] = useState(false);
  
  const handleSave = async () => {
    await updateUser(user.id, formData);
    setOpen(false);
    toast({ title: "User updated successfully" });
  };
  
  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="outline">Edit Profile</Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Edit profile</DialogTitle>
          <DialogDescription>
            Make changes to your profile here. Click save when you're done.
          </DialogDescription>
        </DialogHeader>
        
        <div className="space-y-4 py-4">
          {/* Form fields */}
        </div>
        
        <DialogFooter>
          <Button variant="outline" onClick={() => setOpen(false)}>
            Cancel
          </Button>
          <Button onClick={handleSave}>Save changes</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
```

## Data Table with Sorting and Filtering

```tsx
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  ColumnDef,
  flexRender,
  getCoreRowModel,
  getSortedRowModel,
  useReactTable,
} from "@tanstack/react-table";

// ✅ Good: Type-safe column definitions
const columns: ColumnDef<User>[] = [
  {
    accessorKey: "name",
    header: "Name",
  },
  {
    accessorKey: "email",
    header: "Email",
  },
  {
    id: "actions",
    cell: ({ row }) => {
      const user = row.original;
      
      return (
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" size="sm">
              <MoreHorizontal className="h-4 w-4" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem onClick={() => editUser(user)}>
              Edit
            </DropdownMenuItem>
            <DropdownMenuItem onClick={() => deleteUser(user.id)}>
              Delete
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      );
    },
  },
];

export function DataTable({ data }: { data: User[] }) {
  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
  });
  
  return (
    <div className="rounded-md border">
      <Table>
        <TableHeader>
          {table.getHeaderGroups().map((headerGroup) => (
            <TableRow key={headerGroup.id}>
              {headerGroup.headers.map((header) => (
                <TableHead key={header.id}>
                  {flexRender(header.column.columnDef.header, header.getContext())}
                </TableHead>
              ))}
            </TableRow>
          ))}
        </TableHeader>
        <TableBody>
          {table.getRowModel().rows.map((row) => (
            <TableRow key={row.id}>
              {row.getVisibleCells().map((cell) => (
                <TableCell key={cell.id}>
                  {flexRender(cell.column.columnDef.cell, cell.getContext())}
                </TableCell>
              ))}
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
```

## Toast Notifications

```tsx
import { useToast } from "@/hooks/use-toast";
import { Button } from "@/components/ui/button";

export function NotificationDemo() {
  const { toast } = useToast();
  
  return (
    <Button
      onClick={() => {
        toast({
          title: "Scheduled: Catch up",
          description: "Friday, February 10, 2023 at 5:57 PM",
        });
      }}
    >
      Show Toast
    </Button>
  );
}

// ✅ Good: Different toast variants
toast({
  title: "Success",
  description: "Your changes have been saved.",
});

toast({
  variant: "destructive",
  title: "Uh oh! Something went wrong.",
  description: "There was a problem with your request.",
});

// ✅ Good: Toast with action
toast({
  title: "Undo Action",
  description: "Item deleted successfully.",
  action: (
    <Button variant="outline" size="sm" onClick={() => undoDelete()}>
      Undo
    </Button>
  ),
});
```

## Composition Patterns

```tsx
// ✅ Good: Compose complex layouts
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { ScrollArea } from "@/components/ui/scroll-area";

export function Dashboard() {
  return (
    <div className="container mx-auto p-6">
      <Tabs defaultValue="overview">
        <TabsList>
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="analytics">Analytics</TabsTrigger>
        </TabsList>
        
        <TabsContent value="overview" className="space-y-4">
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            <Card>
              <CardHeader>
                <CardTitle>Total Revenue</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">$45,231.89</div>
              </CardContent>
            </Card>
            {/* More cards */}
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
}
```

## Custom Component Extensions

```tsx
// ✅ Good: Extend shadcn components
import { Button, ButtonProps } from "@/components/ui/button";
import { Loader2 } from "lucide-react";

interface LoadingButtonProps extends ButtonProps {
  loading?: boolean;
}

export function LoadingButton({ loading, children, ...props }: LoadingButtonProps) {
  return (
    <Button {...props} disabled={loading || props.disabled}>
      {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
      {children}
    </Button>
  );
}

// Usage
<LoadingButton loading={isPending} onClick={handleSubmit}>
  Submit
</LoadingButton>
```

## Accessibility Best Practices

```tsx
// ✅ Good: Proper ARIA labels and keyboard navigation
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogTitle,
} from "@/components/ui/dialog";

export function AccessibleDialog() {
  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button aria-label="Open settings dialog">
          Settings
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogTitle>Settings</DialogTitle>
        <DialogDescription>
          Manage your account settings and preferences.
        </DialogDescription>
        {/* Dialog content */}
      </DialogContent>
    </Dialog>
  );
}

// ✅ Good: Form accessibility
<FormField
  control={form.control}
  name="username"
  render={({ field }) => (
    <FormItem>
      <FormLabel>Username</FormLabel>
      <FormControl>
        <Input
          {...field}
          aria-describedby="username-description"
          aria-invalid={!!form.formState.errors.username}
        />
      </FormControl>
      <FormDescription id="username-description">
        This is your public display name.
      </FormDescription>
      <FormMessage />
    </FormItem>
  )}
/>
```

## Theming

```tsx
// app/globals.css
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --primary: 221.2 83.2% 53.3%;
    --primary-foreground: 210 40% 98%;
    /* More theme variables */
  }
  
  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --primary: 217.2 91.2% 59.8%;
    --primary-foreground: 222.2 47.4% 11.2%;
    /* Dark mode values */
  }
}

// ✅ Good: Use theme toggle
import { useTheme } from "next-themes";
import { Button } from "@/components/ui/button";
import { Moon, Sun } from "lucide-react";

export function ThemeToggle() {
  const { theme, setTheme } = useTheme();
  
  return (
    <Button
      variant="outline"
      size="icon"
      onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
    >
      <Sun className="h-5 w-5 rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0" />
      <Moon className="absolute h-5 w-5 rotate-90 scale-0 transition-all dark:rotate-0 dark:scale-100" />
      <span className="sr-only">Toggle theme</span>
    </Button>
  );
}
```

## Never

- ❌ Never modify components in `components/ui` directly (copy and rename instead)
- ❌ Never forget to use the `cn()` utility for class merging
- ❌ Never skip form validation with zod
- ❌ Never forget accessibility attributes (aria-label, etc.)
- ❌ Never hardcode colors (use theme variables)
- ❌ Never import from `shadcn-ui` package (it's copy-paste, not npm)
- ❌ Never skip the `asChild` prop when composing trigger components
- ❌ Never forget to handle loading and error states
- ❌ Never use inline styles instead of Tailwind classes
- ❌ Never forget responsive design (use Tailwind breakpoints)
