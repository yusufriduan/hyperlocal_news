import 'package:hyperlocal_news/models/category_models.dart';

List<CategoryModels> getCategories() {
  List<CategoryModels> category = <CategoryModels>[];

  CategoryModels categoryModels = new CategoryModels(categoryName: "Business");
  category.add(categoryModels);

  categoryModels = new CategoryModels(categoryName: "Entertainment");
  category.add(categoryModels);

  categoryModels = new CategoryModels(categoryName: "General");
  category.add(categoryModels);

  categoryModels = new CategoryModels(categoryName: "Health");
  category.add(categoryModels);

  categoryModels = new CategoryModels(categoryName: "Science");
  category.add(categoryModels);

  categoryModels = new CategoryModels(categoryName: "Sports");
  category.add(categoryModels);
  return category;
}
