#include <stdlib.h>
#include <stdio.h>

struct Node
{
    int val;
    struct Node *left;
    struct Node *right;
};

// Declarations for assembly functions.
struct Node *get(struct Node *root, int val);
int getAtMost(int val, struct Node *root);
struct Node *insert(struct Node *root, int val);
struct Node *make_node(int val);

int main()
{
    // Test make_node.
    struct Node *node = make_node(42);
    printf("make_node(42): val=%d, left=%p, right=%p\n",
           node->val,
           (void *)node->left,
           (void *)node->right);

    // Test insert.
    struct Node *root = NULL;
    root = insert(root, 50);
    root = insert(root, 30);
    root = insert(root, 70);
    root = insert(root, 20);
    root = insert(root, 40);
    root = insert(root, 60);
    root = insert(root, 80);

    printf("\ninserted: 50 30 70 20 40 60 80\n");

    // Test get.
    struct Node *found = get(root, 40);
    printf("get(root, 40): %s (val=%d)\n", found ? "found" : "not found", found ? found->val : -1);

    found = get(root, 55);
    printf("get(root, 55): %s\n", found ? "found" : "not found");

    // Test getAtMost.
    printf("\ngetAtMost(45, root) = %d (expected 40)\n", getAtMost(45, root));
    printf("getAtMost(50, root) = %d (expected 50)\n", getAtMost(50, root));
    printf("getAtMost(75, root) = %d (expected 70)\n", getAtMost(75, root));
    printf("getAtMost(10, root) = %d (expected -1)\n", getAtMost(10, root));
    printf("getAtMost(80, root) = %d (expected 80)\n", getAtMost(80, root));
    printf("getAtMost(20, root) = %d (expected 20)\n", getAtMost(20, root));

    return 0;
}
